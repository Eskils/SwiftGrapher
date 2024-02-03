# SwiftGrapher

A graphing tool for macOS allowing you to write equations as Swift code. This is a very early work in progress.

<img width="1198" alt="Skjermbilde 2024-02-03 kl  11 16 18" src="https://github.com/Eskils/SwiftGrapher/assets/26850613/86b3f816-26d9-4727-91f8-ea313920af70">

> **NOTE:** Requires Swift to be installed at */usr/bin/*.

Works by compiling your code with `swiftc` to a dylib, and then linking at runtime.

## Roadmap
- [x] Zooming in the graph view
- [ ] Syntax highlighting
- [x] Support multiple equations
- [ ] Display compiler errors
- [ ] Automatic compilation
- [x] Hiding function attributes such as `@_cdecl` and `public`

## Tasks which might or might not make it
- [ ] Support computational commands like Intersect, Maxima, Minima, …
- [ ] Support other kinds of curves, like: parametric, radial, complex plane
- [ ] Support 3D graphs
- [ ] Separate version which embeds the Swift compiler

## Contributing

Contributions are welcome and encouraged. Feel free to check out the project, submit issues and code patches.
