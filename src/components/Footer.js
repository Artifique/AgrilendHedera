import React from 'react';

const Footer = () => {
  return (
    <footer className="footer">
      <div className="footer-container">
        <div className="footer-about">
          <h3>Agri-Lend</h3>
          <p>Connecter les agriculteurs et les acheteurs en toute confiance. Notre mission est de promouvoir un commerce équitable et transparent.</p>
        </div>
        <div className="footer-links">
          <h3>Liens rapides</h3>
          <ul>
            <li><a href="#about">À propos</a></li>
            <li><a href="#services">Services</a></li>
            <li><a href="#testimonials">Témoignages</a></li>
            <li><a href="#contact">Contact</a></li>
          </ul>
        </div>
        <div className="footer-social">
          <h3>Suivez-nous</h3>
          <div className="social-icons">
            <a href="https://www.facebook.com" target="_blank" rel="noopener noreferrer"><i className="fab fa-facebook-f"></i></a>
            <a href="https://www.twitter.com" target="_blank" rel="noopener noreferrer
            "><i className="fab fa-twitter"></i></a>
            <a href="https://www.linkedin.com" target="_blank" rel="noopener noreferrer"><i className="fab fa-linkedin-in"></i></a>
            <a href="https://www.instagram.com" target="_blank" rel="noopener noreferrer"><i className="fab fa-instagram"></i></a>
          </div>
        </div>
      </div>
      <div className="footer-bottom">
        <p>&copy; 2025 Agri-Lend. Tous droits réservés.</p>
      </div>
    </footer>
  );
};

export default Footer;