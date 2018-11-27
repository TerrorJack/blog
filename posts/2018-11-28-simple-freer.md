---
title: A simple encoding of the Freer monad
---

Some time ago, I came up with a pretty simple way of implementing Freer monads. After a round of googling, it looks like a variant of the [van Laarhoven free monad](http://r6.ca/blog/20140210T181244Z.html), but still I'd like to do a brief writeup on what it is, and how it came to me :)

Recall the kind signature of `Freer`:

```haskell
data Freer :: (Type -> Type) -> Type -> Type
```

`Freer` takes a GADT encoding an effect, and offers `>>=` for free. Forget about the effect for one second:

```haskell
newtype Freer f a = Freer (forall m . Monad m => m a)
```

This silly version of `Freer` completely ignores `f`, and we can't lift `f a` to `Freer f a`. Yet it's trivial to implement a `Monad` instance for `Freer f`, so we do get `>>=` for free. In this case, lifting `f a` to `Freer f a` is the same saying as "for any `m` which is a `Monad`, I demand a natural transformation from `f` to `m`":

```haskell
newtype Freer f a = Freer (forall m . Monad m => (forall x . f x -> m x) -> m a)
```

It's still trivial to write a `Monad` instance for `Freer f` (just a reader monad). Since we have an extra piece of context which tells us how to convert `f x` to `m x`, it's simple to implement lifting:

```haskell
liftFreer :: f a -> Freer f a
liftFreer m = Freer (\n -> n m)
```

We also need a way to interpret `Freer`:

```haskell
foldFreer :: Monad m => (forall x . f x -> m x) -> Freer f a -> m a
foldFreer n (Freer m) = m n
```

Just supply a natural transformation from `f` to the target monad. To implement a pure fold, just interpret it to `Identity`.

Compared to Oleg Kiselyov's `Freer` implementation, this encoding is much more lightweight: it doesn't use a type-aligned sequence to encode a chain of Kleisli arrows, so you can't pattern match on the head or tail of that chain in O(1) time. This is similar to Edward Kmett's Church-encoded free monads: sacrificing O(1) pattern matching to avoid quadric slowdown of left-associated `>>=` applications. But when you don't really need monadic reflection, this encoding may be useful to you (a complete implementation is available [here](https://github.com/TerrorJack/yuuenchi/blob/master/src/FinalFreer.hs)).

Additional note: we're only handling one single effect in this post. This encoding doesn't prevent you from implementing a coproduct of effects and a full-blown effect system; plenty of `Freer` libraries out there (e.g. `freer-simple`) already demonstrate how to do that :)
