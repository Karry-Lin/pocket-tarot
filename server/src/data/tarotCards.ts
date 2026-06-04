export type Orientation = "upright" | "reversed";

export type TarotCard = {
  cardId: string;
  name: string;
  arcana: "major" | "minor";
  suit: "major" | "wands" | "cups" | "swords" | "pentacles";
  meanings: {
    upright: string;
    reversed: string;
  };
};

const majorCards = [
  ["00", "fool", "The Fool"],
  ["01", "magician", "The Magician"],
  ["02", "high-priestess", "The High Priestess"],
  ["03", "empress", "The Empress"],
  ["04", "emperor", "The Emperor"],
  ["05", "hierophant", "The Hierophant"],
  ["06", "lovers", "The Lovers"],
  ["07", "chariot", "The Chariot"],
  ["08", "strength", "Strength"],
  ["09", "hermit", "The Hermit"],
  ["10", "wheel-of-fortune", "Wheel of Fortune"],
  ["11", "justice", "Justice"],
  ["12", "hanged-man", "The Hanged Man"],
  ["13", "death", "Death"],
  ["14", "temperance", "Temperance"],
  ["15", "devil", "The Devil"],
  ["16", "tower", "The Tower"],
  ["17", "star", "The Star"],
  ["18", "moon", "The Moon"],
  ["19", "sun", "The Sun"],
  ["20", "judgement", "Judgement"],
  ["21", "world", "The World"]
] as const;

const minorRanks = [
  ["01", "ace", "Ace"],
  ["02", "two", "Two"],
  ["03", "three", "Three"],
  ["04", "four", "Four"],
  ["05", "five", "Five"],
  ["06", "six", "Six"],
  ["07", "seven", "Seven"],
  ["08", "eight", "Eight"],
  ["09", "nine", "Nine"],
  ["10", "ten", "Ten"],
  ["11", "page", "Page"],
  ["12", "knight", "Knight"],
  ["13", "queen", "Queen"],
  ["14", "king", "King"]
] as const;

const suits = ["wands", "cups", "swords", "pentacles"] as const;

export const tarotCards: TarotCard[] = [
  ...majorCards.map(([number, slug, name]) => ({
    cardId: `major-${number}-${slug}`,
    name,
    arcana: "major" as const,
    suit: "major" as const,
    meanings: {
      upright: `${name} points to movement, awareness, and a clear invitation to respond consciously.`,
      reversed: `${name} reversed points to delay, resistance, or an inner pattern that needs attention.`
    }
  })),
  ...suits.flatMap((suit) =>
    minorRanks.map(([number, slug, name]) => {
      const title = `${name} of ${capitalize(suit)}`;

      return {
        cardId: `${suit}-${number}-${slug}`,
        name: title,
        arcana: "minor" as const,
        suit,
        meanings: {
          upright: `${title} highlights practical energy, choice, and the visible shape of the situation.`,
          reversed: `${title} reversed highlights friction, imbalance, or energy that has not settled yet.`
        }
      };
    })
  )
];

const tarotCardMap = new Map(tarotCards.map((card) => [card.cardId, card]));

export function getTarotCard(cardId: string): TarotCard | null {
  return tarotCardMap.get(cardId) ?? null;
}

export function isValidCardId(cardId: string): boolean {
  return tarotCardMap.has(cardId);
}

const majorZhNames = [
  "愚者", "魔術師", "女祭司", "女皇", "皇帝",
  "教皇", "戀人", "戰車", "力量", "隱士",
  "命運之輪", "正義", "倒吊人", "死亡", "節制",
  "惡魔", "高塔", "星星", "月亮", "太陽",
  "審判", "世界"
];

const suitZhNames: Record<string, string> = {
  wands: "權杖",
  cups: "聖杯",
  swords: "寶劍",
  pentacles: "星幣"
};

const rankZhNames: Record<string, string> = {
  "01": "王牌",
  "02": "二",
  "03": "三",
  "04": "四",
  "05": "五",
  "06": "六",
  "07": "七",
  "08": "八",
  "09": "九",
  "10": "十",
  "11": "侍者",
  "12": "騎士",
  "13": "皇后",
  "14": "國王"
};

export function getCardDisplayName(cardId: string, locale: "zh-TW" | "en"): string {
  const card = getTarotCard(cardId);
  if (!card) return cardId;

  if (locale === "en") {
    return card.name;
  }

  const parts = cardId.split("-");
  if (parts.length < 3) return card.name;

  if (parts[0] === "major") {
    const index = Number.parseInt(parts[1], 10);
    if (!Number.isNaN(index) && index >= 0 && index < majorZhNames.length) {
      return majorZhNames[index];
    }
  } else {
    const suit = suitZhNames[parts[0]];
    const rank = rankZhNames[parts[1]];
    if (suit && rank) {
      return `${suit}${rank}`;
    }
  }

  return card.name;
}

function capitalize(value: string) {
  return `${value.charAt(0).toUpperCase()}${value.slice(1)}`;
}
