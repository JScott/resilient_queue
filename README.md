This is in no way inherently thread- or process-safe. It's built for one process owning one queue file and not interacting with it asynchronously.
