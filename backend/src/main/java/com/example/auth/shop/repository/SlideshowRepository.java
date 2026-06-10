package com.example.auth.shop.repository;

import com.example.auth.shop.entity.Slideshow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface SlideshowRepository extends JpaRepository<Slideshow, UUID> {
    List<Slideshow> findByPublishedTrueOrderByDisplayOrderAsc();
}
