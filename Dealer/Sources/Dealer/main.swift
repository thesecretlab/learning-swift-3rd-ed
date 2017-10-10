// BEGIN package_main
import DeckOfPlayingCards

var deck = Deck.standard52CardDeck()
deck.shuffle()

for _ in 0...4
{
    guard let card = deck.deal() else
    {
        print("No More Cards!")
        break
    }
    print(card)
}
// END package_main
