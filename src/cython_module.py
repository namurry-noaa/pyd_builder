def add(a, b):
    """Add two numbers."""
    return a + b

def greet(name):
    """Return a greeting."""
    return f"Hello, {name}, from a Cython-compiled PYD!  IT WORKED!"

def compute(n):
    """A trivial loop to show it runs."""
    total = 0
    for i in range(n):
        total += i * i
    return total