# File:           batch_singsolver.jl
# Last changed:   28/09/2023 16:29
# Purpose:        solver for classic batch sizing problem         
# Authors:        Fernando Antonio Marques Schettini   
# Usage: 
# 	HowToExecute:   julia batch_singsolver.jl          
# Dependencies:
#   - JuMP
#   - Cbc

# PROBLEMA DE DIMENSIONAMENTO DE LOTES ILIMITADO
# Formulação multicomodidade

using JuMP, Cbc

model = Model(Cbc.Optimizer)

# Dados de entrada
d = [6, 7, 4, 6, 3, 8]  # demandas
p = [3, 4, 3, 4, 4, 5]  # custo por unidade de producao
h = [1, 1, 1, 1, 1, 1]  # custo por unidade de estoque
c = [12, 15, 30, 23, 19, 45]  # custo fixo de setup

T = length(d)

@variable(model, q[t in 1:T, i in t:T] >= 0)
@variable(model, x[t in 1:T], Bin)
@variable(model, z)

@variable(model, y[t in 1:T])
@variable(model, s[t in 1:T])

# Função objetivo
z = sum(p[t] * q[t, i] for t in 1:T, i in 1:T if t <= i) +
    sum(c[t] * x[t] for t in 1:T) +
    sum(h[t] * q[k, i] for t in 1:T-1, k in 1:T, i in 1:T if k <= t && i >= t+1)

@objective(model, Min, z)

# Restrições
@constraint(model, produz[i in 1:T], sum(q[t, i] for t in 1:i) == d[i])
@constraint(model, setupconstraints[t in 1:T, i in t:T], q[t, i] <= d[i] * x[t])
@constraint(model, calculay[t in 1:T], y[t] == sum(q[t, i] for i in t:T))
@constraint(model, calculas[t in 1:T], s[t] == sum(q[k, i] for k in 1:t, i in t+1:T))

# Imprime o modelo
println(model)

# Otimização do modelo
JuMP.optimize!(model)

# Imprime os valores não zero de produção
# println("VALORES NAO ZERO DE PRODUCAO")
for t in 1:T
    if value(y[t]) > 0.01
        println(t, " ", value(y[t]))
    end
end
