package com.agrilend.backend.service;

import com.agrilend.backend.dto.auth.JwtAuthenticationResponse;
import com.agrilend.backend.dto.auth.LoginRequest;
import com.agrilend.backend.dto.auth.SignupRequest;
import com.agrilend.backend.entity.Buyer;
import com.agrilend.backend.entity.Farmer;
import com.agrilend.backend.entity.User;
import com.agrilend.backend.entity.enums.UserRole;
import com.agrilend.backend.repository.BuyerRepository;
import com.agrilend.backend.repository.FarmerRepository;
import com.agrilend.backend.repository.UserRepository;
import com.agrilend.backend.security.JwtTokenProvider;
import com.agrilend.backend.service.HederaService.HederaAccountInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@Transactional
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FarmerRepository farmerRepository;

    @Autowired
    private BuyerRepository buyerRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider tokenProvider;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private HederaService hederaService;

    public JwtAuthenticationResponse authenticateUser(LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                loginRequest.getEmail(),
                loginRequest.getPassword()
            )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);

        String accessToken = tokenProvider.generateToken(authentication);
        String refreshToken = tokenProvider.generateRefreshToken(authentication);

        User user = userRepository.findByEmail(loginRequest.getEmail())
            .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        return new JwtAuthenticationResponse(
            accessToken,
            refreshToken,
            user.getId(),
            user.getEmail(),
            user.getFirstName(),
            user.getLastName(),
            user.getRole()
        );
    }

    public User registerUser(SignupRequest signUpRequest) {
        if (userRepository.existsByEmail(signUpRequest.getEmail())) {
            throw new RuntimeException("Erreur: L'email est déjà utilisé!");
        }

        User user = new User();
        user.setFirstName(signUpRequest.getFirstName());
        user.setLastName(signUpRequest.getLastName());
        user.setEmail(signUpRequest.getEmail());
        user.setPassword(passwordEncoder.encode(signUpRequest.getPassword()));
        user.setPhone(signUpRequest.getPhone());
        user.setRole(signUpRequest.getRole());
        user.setIsActive(true);

        // Create Hedera Account
        HederaAccountInfo hederaAccount = hederaService.createAccount(user.getEmail());
        user.setHederaAccountId(hederaAccount.getAccountId());
        user.setHederaPrivateKey(hederaAccount.getPrivateKey()); // IMPORTANT: Secure this key properly

        User savedUser = userRepository.save(user);

        if (signUpRequest.getRole() == UserRole.FARMER) {
            Farmer farmer = new Farmer();
            farmer.setUser(savedUser);
            farmer.setFarmName(signUpRequest.getFarmName());
            farmer.setFarmLocation(signUpRequest.getFarmLocation());
            farmer.setFarmSize(signUpRequest.getFarmSize());
            farmerRepository.save(farmer);
            logger.info("Profil Agriculteur créé avec succès pour l'utilisateur: {} (ID: {})", savedUser.getEmail(), farmer.getId());
        } else if (signUpRequest.getRole() == UserRole.BUYER) {
            Buyer buyer = new Buyer();
            buyer.setUser(savedUser);
            buyer.setCompanyName(signUpRequest.getCompanyName());
            buyer.setActivityType(signUpRequest.getActivityType());
            buyer.setCompanyAddress(signUpRequest.getCompanyAddress());
            buyerRepository.save(buyer);
            logger.info("Profil Acheteur créé avec succès pour l'utilisateur: {} (ID: {})", savedUser.getEmail(), buyer.getId());
        }

        // Send welcome notification
        notificationService.sendWelcomeNotification(savedUser);

        return savedUser;
    }

    public JwtAuthenticationResponse refreshToken(String refreshToken) {
        if (!tokenProvider.validateToken(refreshToken)) {
            throw new RuntimeException("Token de rafraîchissement invalide");
        }

        String username = tokenProvider.getUsernameFromToken(refreshToken);
        User user = userRepository.findByEmail(username)
            .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        Authentication authentication = new UsernamePasswordAuthenticationToken(user, null, user.getAuthorities());

        String newAccessToken = tokenProvider.generateToken(authentication);
        String newRefreshToken = tokenProvider.generateRefreshToken(authentication);

        return new JwtAuthenticationResponse(
            newAccessToken,
            newRefreshToken,
            user.getId(),
            user.getEmail(),
            user.getFirstName(),
            user.getLastName(),
            user.getRole()
        );
    }
}