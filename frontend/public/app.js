const api = '/api';
let operador = null;

function $(id) {
    return document.getElementById(id);
}

function celula(tr, texto) {
    const td = document.createElement('td');
    td.textContent = texto == null ? '' : texto;
    tr.append(td);
}

function botao(texto, fn) {
    const b = document.createElement('button');
    b.textContent = texto;
    b.onclick = fn;
    return b;
}

async function entrar() {
    const resp = await fetch(api + '/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ login: $('login').value, senha: $('senha').value })
    });

    if (!resp.ok) {
        $('erro').textContent = 'Usuario ou senha invalidos';
        return;
    }

    operador = await resp.json();
    $('tela-login').hidden = true;
    $('tela-app').hidden = false;
    carregarMaquinas();
    carregarOs();
}

async function carregarMaquinas() {
    const resp = await fetch(api + '/maquinas');
    const lista = await resp.json();
    const tb = $('tb-maquinas');
    tb.replaceChildren();

    lista.forEach(m => {
        const tr = document.createElement('tr');
        celula(tr, m.codigo);
        celula(tr, m.nome);
        celula(tr, m.setor);
        celula(tr, m.status);

        const td = document.createElement('td');
        td.append(botao('Editar', () => editar(m)));
        td.append(botao('Excluir', () => excluir(m.id)));
        tr.append(td);
        tb.append(tr);
    });
}

function editar(m) {
    $('m-id').value = m.id;
    $('m-codigo').value = m.codigo;
    $('m-nome').value = m.nome;
    $('m-setor').value = m.setor == null ? '' : m.setor;
}

function limparForm() {
    $('m-id').value = '';
    $('m-codigo').value = '';
    $('m-nome').value = '';
    $('m-setor').value = '';
}

async function salvarMaquina() {
    const id = $('m-id').value;
    const corpo = {
        codigo: $('m-codigo').value,
        nome: $('m-nome').value,
        setor: $('m-setor').value,
        status: 'ATIVA'
    };

    const url = id ? api + '/maquinas/' + id : api + '/maquinas';
    await fetch(url, {
        method: id ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(corpo)
    });

    limparForm();
    carregarMaquinas();
}

async function excluir(id) {
    await fetch(api + '/maquinas/' + id, { method: 'DELETE' });
    carregarMaquinas();
}

async function carregarOs() {
    const resp = await fetch(api + '/os');
    const lista = await resp.json();
    const tb = $('tb-os');
    tb.replaceChildren();

    lista.forEach(o => {
        const tr = document.createElement('tr');
        celula(tr, o.os_id);
        celula(tr, o.maquina);
        celula(tr, o.tecnico);
        celula(tr, o.status);
        celula(tr, o.custo_total);

        const td = document.createElement('td');
        td.append(botao('Aprovar', () => aprovar(o.os_id)));
        tr.append(td);
        tb.append(tr);
    });
}

async function aprovar(id) {
    await fetch(api + '/os/' + id + '/aprovar?operadorId=' + operador.id, { method: 'POST' });
    carregarOs();
}
