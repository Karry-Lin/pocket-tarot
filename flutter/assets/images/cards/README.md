# 塔羅牌圖像資源說明

這裡存放的 `*-*.jpg` 牌面資源，皆是來自 Wikimedia Commons 上無版權（Public Domain）的「萊德偉特塔羅牌（Rider-Waite-Smith Tarot Deck）」圖像：

- 來源網址：https://commons.wikimedia.org/wiki/Category:Rider-Waite-Smith_tarot_deck_(TaionWC)

## 命名規則

所有檔案的命名方式皆精準對應 `assets/data/tarot_cards.json` 中的 `id` 欄位（例如：`major-00-fool.jpg`、`swords-01.jpg`）。這讓 Flutter 可以透過 `assets/images/cards/<cardId>.jpg` 動態載入並顯示正確的牌面。

