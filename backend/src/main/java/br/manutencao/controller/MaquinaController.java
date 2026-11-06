package br.manutencao.controller;

import br.manutencao.model.Maquina;
import br.manutencao.repository.MaquinaRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/maquinas")
public class MaquinaController {

    private final MaquinaRepository repo;

    public MaquinaController(MaquinaRepository repo) {
        this.repo = repo;
    }

    @GetMapping
    public List<Maquina> listar() {
        return repo.findAll();
    }

    @PostMapping
    public Maquina criar(@RequestBody Maquina m) {
        m.setId(null);
        if (m.getStatus() == null) {
            m.setStatus("ATIVA");
        }
        return repo.save(m);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Maquina> atualizar(@PathVariable Long id, @RequestBody Maquina m) {
        if (!repo.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        m.setId(id);
        return ResponseEntity.ok(repo.save(m));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        if (!repo.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        repo.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}