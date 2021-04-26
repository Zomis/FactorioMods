# LTN Tips and Tricks

Because of the popularity of the LTN mod, I decided to write these tips and tricks for using LTN.

It's good to have a basic understanding about LTN before reading this.

## The importance of empty wagons in the depot

Many other issues you can experience when using LTN comes from the fact that your cargo/fluid wagons are not empty when they go back to the depot.

A simple start to keep an eye on this is to connect an alarm using green/red wires to all your depot stations and have the stations read train contents. Then have it go off on the signal ANYTHING > 0.

(TODO: Write about how to disable depot exit if a train have had items in it)
(TODO: Write about what to do if there is no power for the alarm: Disable entrance to depot)

## Don't request too much

If you have space for 8000 of something, you should normally not request 8000 of it. The reason is that unless you have done some circuit magic to control how much is loaded onto a train, the wagons will be filled as much as possible. So when the train arrives to the requester, it unloads EVERYTHING. So there should always be much more space to store stuff than what you are actually requesting. This is important for both items and fluids.

For fluids requester stations, it's a good idea to use the "Requester Threshold" signal and set it to about 15k. This is to prevent LTN from issuing multiple requests too quickly which would overflow the tank. It's also a good idea to have some extra fluid space in your fluid requester station.

## Bad train size?

A common reason for why a train returns to depot still with items in it is that the train station for loading supports a train of a bigger size than the station unloading the train. It's a good practice to specify the train size at each station, both on provider and requester stations.

## Inserter amount and speed

To ensure that a train does not return to the depot with items, the inserters that are unloading the train should always be more/faster or equal to the inserters that are loading the train.

## My trains are trying to load an item on the wrong stations! (typically a requesting station instead of a provider station)

This is because more items are available in the requesting station than what is being requested.

An easy fix is to connect a constant combinator to the requesting station with the signal "Provider threshold" set to 10 million (or some ridiculously large number). This will make LTN only consider that station as a provider if there is more than 10 million of an item there, which should never happen.
