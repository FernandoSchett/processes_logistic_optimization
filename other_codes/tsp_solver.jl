# PROBLEMA DO CAIXEIRO VIAJANTE
# Formulação de Miller-Tucker-Zemlin

using JuMP, Cbc

# Definição da matriz de custos c
c = [
    0 3 5 48 48 8;
    3 0 3 48 48 8;
    5 3 0 72 72 48;
    48 48 74 0 0 6;
    48 48 74 0 0 6;
    8 8 50 6 6 0
]

# Número de nós
n = length(c[1, :])

# Criação do modelo de otimização
m = Model(Cbc.Optimizer)

# Variáveis de decisão: x[i,j] indica se a aresta entre i e j está no caminho
@variable(m, x[i in 1:n, j in 1:n; i != j], Bin)

# Variáveis de decisão: u[i] é o valor associado ao nó i no ciclo
@variable(m, 0 <= u[i in 1:n] <= n-1)

# Função objetivo: minimizar a soma dos custos das arestas no caminho
@objective(m, Min, sum(x[i, j] * c[i, j] for i in 1:n, j in 1:n if i != j))

# Restrição: cada nó deve ser alcançado uma única vez
@constraint(m, arriving[i in 1:n], sum(x[j, i] for j in 1:n if i != j) == 1)
@constraint(m, leaving[i in 1:n], sum(x[i, j] for j in 1:n if i != j) == 1)

# Restrição de subtour: evita ciclos subtours
@constraint(m, subtourelim[i in 2:n, j in 2:n; i != j], u[i] - u[j] + n * x[i, j] <= n-1)

# Restrição: definir o valor inicial de u[1]
@constraint(m, u[1] == 0)

# Limitar o tempo de execução do solver
set_time_limit_sec(m, 30)

# Resolver o problema
optimize!(m)

# Imprimir as arestas do caminho
for i in 1:n, j in 1:n
    if i != j && value(x[i, j]) > 0.1
        println(i, "->", j, " custo ", c[i, j])
    end
end
