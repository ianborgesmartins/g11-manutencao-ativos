package br.manutencao.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class OperacaoController {

    private final JdbcTemplate jdbc;

    public OperacaoController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        List<Long> ids = jdbc.queryForList(
            "SELECT id FROM operacional.operador WHERE login = ? AND senha_hash = ext.crypt(?, senha_hash)",
            Long.class, body.get("login"), body.get("senha"));

        if (ids.isEmpty()) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(Map.of("id", ids.get(0), "login", body.get("login")));
    }

    @GetMapping("/os")
    public List<Map<String, Object>> listarOs() {
        return jdbc.queryForList("SELECT * FROM operacional.vw_os_detalhada ORDER BY os_id");
    }

    @PostMapping("/os/{id}/aprovar")
    public ResponseEntity<Void> aprovar(@PathVariable int id, @RequestParam int operadorId) {
        jdbc.update("CALL financeiro.sp_aprovar_os(?, ?)", id, operadorId);
        return ResponseEntity.ok().build();
    }
}