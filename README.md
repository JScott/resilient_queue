# stubborn_queue

Sometimes you want to make sure that stuff on your queue gets done. This stubborn queue will insist that something isn't done until you tell it otherwise. Unfinished items get requeued after a specified amount of time because you didn't do it right. I store the data in file to avoid dependencies outside of Ruby itself.

## Heads up!

This is in no way inherently thread- or process-safe. It's built for one process owning one queue file and not interacting with it asynchronously.

## Special thanks

Huge props to [Chris Olstrom](https://github.com/colstrom) who helped me understand the idea and was a good sport when I made my own implementation which will probably be extremely similar to his.
