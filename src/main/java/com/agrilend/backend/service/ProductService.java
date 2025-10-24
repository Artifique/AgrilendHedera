package com.agrilend.backend.service;

import com.agrilend.backend.dto.product.ProductDto;
import com.agrilend.backend.entity.Product;
import com.agrilend.backend.repository.ProductRepository;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ModelMapper modelMapper;

    // This is an administrative action
    public ProductDto createProduct(ProductDto productDto) {
        Product product = modelMapper.map(productDto, Product.class);
        Product savedProduct = productRepository.save(product);
        return modelMapper.map(savedProduct, ProductDto.class);
    }

    // This is an administrative action
    public ProductDto updateProduct(Long productId, ProductDto productDto) {
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new RuntimeException("Produit non trouvé avec l'ID: " + productId));

        // Map fields from DTO to entity
        product.setName(productDto.getName());
        product.setDescription(productDto.getDescription());
        product.setCategory(productDto.getCategory());
        product.setSubcategory(productDto.getSubcategory());
        product.setUnit(productDto.getUnit());
        product.setImageUrl(productDto.getImageUrl());

        Product updatedProduct = productRepository.save(product);
        return modelMapper.map(updatedProduct, ProductDto.class);
    }

    // Deactivate instead of deleting to preserve historical data
    public void deactivateProduct(Long productId) {
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new RuntimeException("Produit non trouvé avec l'ID: " + productId));
        product.setIsActive(false);
        productRepository.save(product);
    }

    public void activateProduct(Long productId) {
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new RuntimeException("Produit non trouvé avec l'ID: " + productId));
        product.setIsActive(true);
        productRepository.save(product);
    }

    public ProductDto getProductById(Long productId) {
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new RuntimeException("Produit non trouvé avec l'ID: " + productId));
        return modelMapper.map(product, ProductDto.class);
    }

    public Page<ProductDto> getAllProducts(Pageable pageable) {
        Page<Product> products = productRepository.findAll(pageable);
        return products.map(product -> modelMapper.map(product, ProductDto.class));
    }

    public Page<ProductDto> searchProducts(String keyword, Pageable pageable) {
        Page<Product> products = productRepository.findByNameContainingIgnoreCaseOrCategoryContainingIgnoreCase(keyword, keyword, pageable);
        return products.map(product -> modelMapper.map(product, ProductDto.class));
    }
}