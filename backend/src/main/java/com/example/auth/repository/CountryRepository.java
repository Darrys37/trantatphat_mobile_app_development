package com.example.auth.repository;

import com.example.auth.entity.Country;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface CountryRepository extends JpaRepository<Country, Integer> {
    Optional<Country> findByIso(String iso);
    Optional<Country> findByName(String name);
}
