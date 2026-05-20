import { tarotCards, type Orientation, type TarotCard } from "../data/tarotCards.js";

export type CardDraw = {
  cardId: string;
  orientation: Orientation;
};

export function drawCards(count: number): CardDraw[] {
  const shuffled = [...tarotCards].sort(() => Math.random() - 0.5);

  return shuffled.slice(0, count).map(toCardDraw);
}

export function getCardForPrompt(draw: CardDraw): TarotCard & { orientation: Orientation } {
  const card = tarotCards.find((item) => item.cardId === draw.cardId);

  if (!card) {
    throw new Error(`Unknown card id: ${draw.cardId}`);
  }

  return {
    ...card,
    orientation: draw.orientation
  };
}

function toCardDraw(card: TarotCard): CardDraw {
  return {
    cardId: card.cardId,
    orientation: Math.random() < 0.5 ? "upright" : "reversed"
  };
}
