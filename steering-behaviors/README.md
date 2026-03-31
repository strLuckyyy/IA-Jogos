# Projeto - Steering Behaviors

Este projeto tem o objetivo de entender e implementar diferentes tipos de comportamentos baseados nos estudos de Ian Milington sobre Inteligencia Artificial para Jogos

</br>

## Como Utilizar

**Execução**:
   - Clone o repositório.
   - Abra o projeto no Godot **OU** rode o `.exe` na pasta /exe na raiz do projeto.

**Controles**:
   - **WASD**: Movimenta o Player
   - **Teclas 1 a 7**: Alterna entre os modos de comportamento dos agentes.
   - **Q (Segurar)**: Exibe o menu de ajuda e comandos.
   - **T**: Ativa/Desativa as linhas de Debug (Vetores).
   - **E**: Ativa/Desativa as colisões dos Agentes.
   - **Esc**: Fecha a simulação.

</br>

## 🧠 Steering Behaviors Implementados

Abaixo estão os comportamentos baseados na teoria de Craig Reynolds e Ian Millington presentes neste projeto:

* **Seek (Buscar)**: O agente move-se diretamente em direção ao player.
* **Flee (Fugir)**: O agente move-se na direção oposta ao player.
* **Pursuit (Perseguição)**: O agente prevê a posição futura do player para interceptá-lo.
* **Evasion (Evasão)**: O agente prevê a posição futura do player para fugir dela.
* **Wander (Errante)**: O agente movimenta-se de forma aleatória e suave usando um círculo de projeção.
* **Leader Following**: Os agentes seguem o player mantendo uma distância de segurança atrás dele.
* **Flocking (Bando)**: Comportamento de grupo emergente baseado em Separação, Alinhamento e Coesão.

</br>

## 📂 Estrutura do Código

O código é gerenciado pelo GameManager, responsável por definições, modos, inputs e signals. 

Ao iniciar o programa, o GameManager envia as informações para o Spawner, que instancia os Agents na cena.

Como o GameManager é um Singleton, suas variáveis e métodos podem ser acessados globalmente, permitindo que outras classes utilizem esses dados sem depender de referências diretas.

As classes Steering Behaviors e Agent fazem uso dessas varíaveis globais presentes no GameManager. Como há diversos Agents em cena, essa abordagem facilita a comunicação e mantém a consistência entre os comportamentos.

- **SCRIPT FOLDER**
* `./scripts/game_manager.gd`: Singleton que gerencia o estado global, inputs e signals.
* `./scripts/hud.gd`: Gerencia a HUD.
* `./scripts/utils.gd`: Classe utilitária para factory de comportamentos.

</br>

- **/S/ENTITY FOLDER**
* `./scripts/entity/agent.gd`: Classe principal dos NPCs; executa o behavior selecionado e interage com o GameManager.
* `./scripts/entity/agent_spawner.gd`: Responsável por instânciar Agents em posições aleatória dentro de um raio de 50px.
* `./scripts/entity/agent_sprite.gd`: Gerencia a troca de sprites via metadata com base no behavior.
* `./scripts/entity/player.gd`: Lida com o movimento do PLayer.


</br>

- **/S/STEERING FOLDER**
* `./scripts/steering/steering_behavior.gd`: Classe base dos steering behaviors; contém variáves e métodos comuns.
* `./scripts/steering/*`: Cada arquivo implementa um comportamento específico.

A lógica de movimento é concentrada no método _calculate_force(agent: Agent), para que os Agents só precisem chamar pelo método durante a execução.

</br>

## Desafios e Soluções

Tive dificuldades iniciais para compreender algumas lógicas, principalmente Pursuit, Evasion e Flocking. Como prefiro implementar as coisas de forma mais modular, acabei entrando em um loop de estudo: assistia vídeos, tentava implementar, analisava o resultado, pesquisava como melhorar o código e repetia esse processo.

Também enfrentei problemas extras por escolha de design. Como decidi usar uma câmera fixa, precisei encontrar uma forma de impedir que os Agents saíssem da tela. A solução foi adicionar colisões nos limites da câmera, mas isso acabou gerando outro problema: alguns Agents simplesmente batiam na parede e continuavam tentando se mover “ao infinito”, como se não houvesse obstáculo.

Por conta disso, tive que implementar um sistema de detecção de paredes. Mesmo assim, essa lógica acabou interferindo bastante nos comportamentos, principalmente porque o método calculate_wall influenciava diretamente no movimento dos Agents, deixando alguns deles meio “malucos” dependendo da situação.

Outro ponto que foi mais difícil do que eu esperava foi a linha de debug. Em vários momentos, a direção das linhas não batia com a direção real do movimento dos Agents, o que dificultava bastante o entendimento do que estava acontecendo.

Além disso, comportamentos como Flee e Pursuit apresentaram tremedeiras e bugs bem estranhos. No geral, muitos desses problemas estavam relacionados à combinação das forças de movimento com a lógica de colisão.

No fim, consegui resolver boa parte desses problemas e chegar em um resultado minimamente agradável.

</br>

## Referências Consultadas

* Canais de Youtube como: Martinator, ASamBlur e The Coding Train
* REYNOLDS, Craig W. **Steering Behaviors For Autonomous Characters**. 1999.
* MILLINGTON, Ian. **AI for Games**. 2ª Edição, Morgan Kaufmann, 2009.
* Documentação Oficial Godot Engine (Vector Math & Physics).
