package com.test;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/")
public class CICDTestController {

    @GetMapping("/test")
    public ResponseEntity<String> testCICD() {

        return new ResponseEntity<>("CI/CD test is sussessfull", HttpStatus.OK);
    }
}
