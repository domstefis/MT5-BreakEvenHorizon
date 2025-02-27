# What it is
A little tool called BreakEvenHorizon that I’m excited to share with you all (MIT License—use it, tweak it, share it, just give me a nod). This Expert Advisor (EA) is designed for MetaTrader 5 and helps you visualize your break-even point when juggling multiple positions on the same symbol.

# What it does

BreakEvenHorizon scans your open positions on the current chart’s symbol, finds the oldest and newest trades, and draws a horizontal line right at the midpoint price between them. That line? It’s your break-even horizon—the exact level where your gains and losses from those trades would balance out to zero. It updates automatically (every 5 seconds by default, but you can tweak that), and if you’ve got fewer than 2 positions, it cleans itself up and disappears until you’re back in the game.

# Why it’s useful

**Clarity**: Instantly see where you stand without crunching numbers manually.

**Strategy**: Perfect for managing multi-position trades or hedging setups where break-even is key.

**Customizable**: Adjust the line’s color, width, style, and update frequency to fit your vibe.

# How to use it

Compile it using MetaEditor, then drop it on your MT5 chart, tweak the inputs if you want (green solid line by default), and let it do its thing. It’s lightweight, only updates when needed, and redraws smoothly if you switch timeframes.

I built this to help myself, but I figured some of you might find it handy too. Grab the code, try it out, and let me know what you think — or remix it and share your own spin! Happy trading, and may your break-even horizons always be in sight.

—domstefis
