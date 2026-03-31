# Projeto - Steering Behaviors

Este projeto tem o objetivo de entender e implementar diferentes tipos de comportamentos envolvendo os trabalhos de Milington sobre Inteligencia Artificial para Jogos

</br>

## Como Utilizar

**Execução**:
   - Clone o repositório.
   - Abra o projeto no Godot OU rode o .exe na pasta /exe na raiz do projeto.

**Controles**:
   - **AWSD**: Movimenta o Player
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

O código é gerenciado pelo GameManager, ele lida com definições, modos, inputs e signals. Ao iniciar o programa, ele envia as informações para o Spawner para que possa invocar os Agents.
Como o GameManager é Singleton, posso chamar suas variáveis e métodos de "longe", o que me permite utilizar esses dados em outras classes sem que elas necessitem referenciar o GameManager em si.
As classes Steering Behaviors possuem muitas manipulações de valores que envolvem as variáveis presentes no GameManager. Como são diversos Agents em cena essa abordagem facilita a comunicação e coerencia entre eles.

- **SCRIPT FOLDER**
* `./scripts/game_manager.gd`: Singleton que gerencia o estado global, inputs e sinais da interface.
* `./scripts/hud.gd`: Script simples que gerencia a hud.
* `./scripts/utils.gd`: Classe utilitária para factory de comportamentos.

</br>

- **/S/ENTITY FOLDER**
* `./scripts/entity/agent.gd`: Script principal dos NPCs que possui as informações base dos Agents, roda a lógica do behavior selecionado e interage com alguns signals do GameManager.
* `./scripts/entity/agent_spawner.gd`: Spawner dinâmico dos Agents na cena. Roda quando o programa é iniciado colocando os Agents em uma posição aleatória dentro de um raio de 50px.
* `./scripts/entity/agent_sprite.gd`: Script simples que lida com a troca de sprites via Metadata com base no behavior atualmente selecionado.
* `./scripts/entity/player.gd`: Classe que lida com o movimento do Player.


</br>

- **/S/STEERING FOLDER**
* `./scripts/steering/steering_behavior.gd`: Classe pai de todos os steering behaviors presentes no projeto. Aqui tem a declaração e implementação de variáveis e métodos muito utilizados pelos behaviors.
* `./scripts/steering/{demais arquivos}`: Cada um lida com um steering behavior separadamente, a lógica de movimento é concentrada no método _calculate_wall(agent: Agent) para que os Agents só precisem chamar pelo método durante a execução.

</br>

## 🛠 Desafios e Soluções

* **Tremor em Obstáculos**:
    * *Desafio*: Ao utilizar médias de vetores para desviar de paredes, os agentes vibravam intensamente.
    * *Solução*: Implementação de um sistema de "Antenas" (Raycasts frontais) utilizando a **Normal** da colisão para gerar uma força de repulsão direta e estável.
* **Atualização da HUD**:
    * *Desafio*: O texto da ajuda não atualizava ao segurar a tecla.
    * *Solução*: Implementação de um sistema de Sinais (`signals`) no `GameManager` com `setters` que notificam a interface apenas quando o estado muda.

</br>

## 📚 Referências Consultadas

* REYNOLDS, Craig W. **Steering Behaviors For Autonomous Characters**. 1999.
* MILLINGTON, Ian. **AI for Games**. 2ª Edição, Morgan Kaufmann, 2009.
* Documentação Oficial Godot Engine (Vector Math & Physics).
* [Adicione aqui vídeos ou cursos que você assistiu, como Udemy ou tutoriais de Godot]
