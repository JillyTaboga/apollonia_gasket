# Apollonian Gasket

Um pequeno projeto de estudo sobre o fractal Apollonian Gasket que consiste em apartir de 3 círculos tangenciais criar um novo círculo tangencial e na sequência continuar criando circulos tangenciais a cada 3 anteriores.

<https://en.wikipedia.org/wiki/Apollonian_gasket>

Esse projeto foi inspirado na aula do professor The Coding Train <https://www.youtube.com/watch?v=6UlGLB_jiCs>, incluindo boa parte do código de número complexo que ele utiliza, apesar da geração de círculos não possuir direta relação.

## Métodos de criação

1. É criado um primeiro círculo com diâmetro baseado na menor medida disponível no display
2. Baseado no clique ou no drag/pan é criado um círculo interno com centro no ponto e raio tangencial ao círculo externo
3. Então é criao um segundo cículo interno com raio igual a diferença do diametro do círculo externo ao diâmetro do primeiro círculo interno e centro posicionado no angulo entre os dois centros utilizando trigonometria e as propriedades do círculo unitário
4. Com os três círculos tangenciais se aplica o Teorema de Descartes <https://en.wikipedia.org/wiki/Descartes%27_theorem> para encontrar a curvatura dos próximos círculos tangenciais
5. Com as curvaturas do novos círculos tangenciais é calculado o centro possíveis desses novos círculos utilizando o Teorema de Descartes complexo
6. Em posse dos novos círculos é criado um loop para criar novos círculos tangenciais a cada conjunto de 3 novos círculos tangenciais

## Estrutura do projeto

O projeto utilizou Signals para controle de estado e uma simples divisão das entidades objetos da interface.

## Observações

- As formulas quadráticas foram retiradas direto do artigo da wikipedia <https://en.wikipedia.org/wiki/Descartes%27_theorem>
- O dart dispõe de packages com classes para Número complexos, mas seguindo o vídeo do professor Coding Train criei minha própria classe para fins de estudo, apesar de boa parte do código ter sido observado no código do mesmo vídeo
- Toda a interface e métodos de criação dos círculso foram mantidos no mesmo arquivo [lib\presentation\home_screen.dart] para facilitar as pessoas que desejem estudar o código

## Exemplo

- O projeto foi testado e é mais funcional pensando em uma aplicação windows
- Mas também roda em plataforma web (exemplo abaixo) contudo em navegadores móbiles a experiência é bem reduzida, tanto pelo tamanho da interface, quanto desempenho e a falta da finesse do mouse

![PrintScreen](descater.png "Screenshot")
