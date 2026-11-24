package org.isetn;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ScolA7Application {

    public static void main(String[] args) {
        SpringApplication.run(ScolA7Application.class, args);
        System.out.println("==================================================");
        System.out.println("  Scol_A7 Backend démarré sur http://localhost:8081");
        System.out.println("  Connexion MySQL XAMPP : scol_db sur port 3306");
        System.out.println("==================================================");
    }
}
