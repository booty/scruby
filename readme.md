
Want YJIT-enabled Ruby 3.2.x?


Uninstall it if it's already installed:

```bash
asdf uninstall ruby 3.2.0
```

Reinstall with YJIT. This will perhaps ~5 minutes.

```bash
asdf plugin-add rust
asdf install rust latest
asdf global rust latest
asdf plugin update ruby
export RUBY_CONFIGURE_OPTS=--enable-yjit
asdf install ruby 3.2.0
asdf global ruby 3.2.0
```

Confirm with `ruby -v --enable-yjit`, which should return something like:

```
ruby 3.2.0 (2022-12-25 revision a528908271) +YJIT [x86_64-darwin22]
```

Run with yjit:

```bash
ruby --enable-yjit scruby.rb   # or whatever file
```