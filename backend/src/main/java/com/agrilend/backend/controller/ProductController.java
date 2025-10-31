package com.agrilend.backend.controller;

import com.agrilend.backend.dto.common.ApiResponse;
import com.agrilend.backend.dto.common.PageResponse;
import com.agrilend.backend.dto.product.ProductDto;
import com.agrilend.backend.service.ProductService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/products")
@Tag(name = "Products", description = "API pour la gestion des produits")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ProductController {

    @Autowired
    private ProductService productService;

    @GetMapping
    @Operation(summary = "Obtenir tous les produits", description = "Récupère la liste paginée de tous les produits")
    public ResponseEntity<ApiResponse<PageResponse<ProductDto>>> getAllProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        Sort sort = sortDir.equalsIgnoreCase("desc") ?
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<ProductDto> products = productService.getAllProducts(pageable);

        PageResponse<ProductDto> pageResponse = new PageResponse<>(
            products.getContent(),
            products.getNumber(),
            products.getSize(),
            products.getTotalElements(),
            products.getTotalPages(),
            products.isFirst(),
            products.isLast(),
            products.isEmpty()
        );

        return ResponseEntity.ok(ApiResponse.success("Produits récupérés avec succès", pageResponse));
    }

    @GetMapping("/{productId}")
    @Operation(summary = "Obtenir un produit par ID", description = "Récupère les détails d'un produit spécifique")
    public ResponseEntity<ApiResponse<ProductDto>> getProductById(@PathVariable Long productId) {
        ProductDto product = productService.getProductById(productId);
        return ResponseEntity.ok(ApiResponse.success("Produit récupéré avec succès", product));
    }

    @GetMapping("/search")
    @Operation(summary = "Rechercher des produits", description = "Recherche des produits par nom ou catégorie")
    public ResponseEntity<ApiResponse<PageResponse<ProductDto>>> searchProducts(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<ProductDto> products = productService.searchProducts(keyword, pageable);

        PageResponse<ProductDto> pageResponse = new PageResponse<>(
            products.getContent(),
            products.getNumber(),
            products.getSize(),
            products.getTotalElements(),
            products.getTotalPages(),
            products.isFirst(),
            products.isLast(),
            products.isEmpty()
        );
        return ResponseEntity.ok(ApiResponse.success("Produits trouvés avec succès", pageResponse));
    }
}
