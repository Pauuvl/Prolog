% Definiciones de hombres y mujeres
male(ardojan).
male(vladislav).
male(laurentis).
male(imre).
male(aurel).
male(gergely).
male(matyas).
male(baltasar).

female(petronya).
female(klara).
female(elzbieta).
female(abelia).
female(magdolna).

% Relaciones de parentesco
parent(ardojan, aurel).
parent(klara, aurel).
parent(ardojan, petronya).
parent(klara, petronya).
parent(ardojan, baltasar).
parent(klara, baltasar).
parent(abelia, imre).
parent(gergely, imre).
parent(abelia, magdolna).
parent(gergely, magdolna).
parent(abelia, laurentis).
parent(gergely, laurentis).
parent(laurentis, elzbieta).
parent(laurentis, vladislav).
parent(petronya, elzbieta).
parent(petronya, vladislav).
parent(matyas, abelia).
parent(matyas, klara).

% Relación de padre
father(X, Y) :- parent(X, Y), male(X).

% Relación de madre
mother(X, Y) :- parent(X, Y), female(X).

% Relación de hermano
brother(X, Y) :- parent(Z, X), parent(Z, Y), male(X), X \= Y.

% Relación de hermana
sister(X, Y) :- parent(Z, X), parent(Z, Y), female(X), X \= Y.

% Relación de abuela
grandma(X, Y) :- parent(X, Z), parent(Z, Y), female(X),X \= Y.

% Relación de abuelo
grandpa(X, Y) :- parent(X, Z), parent(Z, Y), male(X), X \= Y.


% Relación de tío
uncle(X, Y) :- parent(Z, Y), brother(X, Z),X \= Y.


% Relación de tía
aunt(X, Y) :- parent(Z, Y), sister(X, Z),X \= Y.


% Relación de primo
cousin(X, Y) :- parent(A, X), parent(B, Y), (brother(A, B); sister(A, B)),X \= Y.



% Nivel de consanguinidad simplificado
lc(X, Y, 1) :- father(X, Y).
lc(X, Y, 1) :- mother(X, Y).
lc(X, Y, 2) :- brother(X, Y).
lc(X, Y, 2) :- sister(X, Y).
lc(X, Y, 2) :- grandpa(X, Y).
lc(X, Y, 2) :- grandma(X, Y).
lc(X, Y, 3) :- uncle(X, Y).
lc(X, Y, 3) :- aunt(X, Y).
lc(X, Y, 3) :- cousin(X, Y).

% Porcentajes de herencia por nivel de consanguinidad
porcentaje_nivel(1, 0.50). % Padres, hijos: 50%
porcentaje_nivel(2, 0.30). % Hermanos, abuelos: 30%
porcentaje_nivel(3, 0.20). % Tíos, primos: 20%

% Obtener los porcentajes de cada nivel de consanguinidad
calcular_total_porcentajes([], 0).
calcular_total_porcentajes([_-Nivel | Rest], TotalPorcentaje) :-
    porcentaje_nivel(Nivel, Porcentaje),
    calcular_total_porcentajes(Rest, PorcentajeRestante),
    TotalPorcentaje is Porcentaje + PorcentajeRestante.

% Ajustar los porcentajes cuando el total excede 100%
ajustar_porcentaje(Nivel, TotalPorcentaje, ProporcionAjustada) :-
    porcentaje_nivel(Nivel, Porcentaje),
    ProporcionAjustada is Porcentaje / TotalPorcentaje.

% Calcular la parte proporcional ajustada y redondeada si el total de los porcentajes supera el 100%
calcular_parte_proporcional(Nivel, Inheritance, TotalPorcentaje, ParteRedondeada) :-
    ajustar_porcentaje(Nivel, TotalPorcentaje, ProporcionAjustada),
    Parte is Inheritance * ProporcionAjustada,
    round(Parte, ParteRedondeada). % Redondear a números enteros

% Obtener herederos únicos de la persona fallecida con su nivel de consanguinidad
herederos(Persona, Inheritance, Distribucion) :-
    findall(Heredero-Nivel, lc(Heredero, Persona, Nivel), Herederos),
    sort(Herederos, HerederosUnicos),  % Eliminar duplicados
    calcular_total_porcentajes(HerederosUnicos, TotalPorcentaje),
    distribuir_herencia(Inheritance, TotalPorcentaje, HerederosUnicos, Distribucion).

% Distribuir la herencia entre los herederos
distribuir_herencia(_, _, [], []).  % Caso base: sin herederos
distribuir_herencia(Inheritance, TotalPorcentaje, [Heredero-Nivel | Rest], [Heredero-Parte | Distribucion]) :-
    calcular_parte_proporcional(Nivel, Inheritance, TotalPorcentaje, Parte),
    distribuir_herencia(Inheritance, TotalPorcentaje, Rest, Distribucion).

% Consulta para distribuir la herencia
calcular_herencia(Persona, Inheritance) :-
    herederos(Persona, Inheritance, Distribucion),
    write('Distribución de la herencia: '), nl,
    mostrar_distribucion(Distribucion).

% Mostrar la distribución de manera clara con números redondeados
mostrar_distribucion([]).
mostrar_distribucion([Heredero-Parte | Rest]) :-
    write(Heredero), write(' recibe $'), write(Parte), nl,
    mostrar_distribucion(Rest).


