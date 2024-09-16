package org.example;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class PersonController {

    @Autowired
    private PersonRepository personRepository;

    @GetMapping("/persons")
    public List<Person> getAllPersons() {
        List<Person> all = personRepository.findAll();
//        System.out.println(all);
        return all;
    }
}
