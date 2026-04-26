---
title: "Splice - The Color Wheel That Punishes Hesitation"
date: 2026-04-26
categories: [Games, Mobile]
tags: [flutter, timing, hyper-casual, android]
excerpt: "A wheel of colors spins under a notch. Tap when the right color passes. Speed climbs. Segments multiply. You will hesitate. You will lose."
featured_image: /assets/games/splice-feature.png
---

## The Loop That Lives In Your Reflexes

**Splice** distills tap-timing to its purest form. A color wheel spins beneath a yellow notch. Above, a tile shows the color you must hit. When that segment crosses the notch, tap. Miss by a hair and the run ends.

Every successful tap speeds the wheel up. Every fifth tap adds a new color segment. Every fourth tap reverses the spin direction. By the time you have twenty hits, the game has become a chase between your eyes and your thumb.

## Why It Sticks

Most arcade games tell you when to act. Splice forces you to **find the moment yourself**. There is no audio cue, no visual tell beyond the rotation. Your brain builds a model of the wheel speed and predicts when the target will arrive at the notch.

Get the prediction right and the dopamine arrives like clockwork. Get it wrong and you are back to round one with the lesson burned into your hand.

## Built In Flutter

A `Ticker` advances the rotation angle each frame. On tap, the game computes which segment sits under the notch using a single modular-arithmetic expression. Match the target index and score. Otherwise game over.

The painter uses `Canvas.drawArc` per segment. Eight colors max, six on round one. No images, no shaders, no shaders.

## Try It

Source, custom icon, sound effect, release APK on GitHub. Sideload, find your tempo, then try the reversed spin.
