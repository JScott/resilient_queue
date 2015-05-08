This is in no way inherently thread- or process-safe. It's built for one process owning one queue file and not interacting with it asynchronously.

Huge props to [Chris Olstrom](https://github.com/colstrom) who helped me understand the idea and was a good sport when I implemented my own version instead of waiting for him to finish his.
