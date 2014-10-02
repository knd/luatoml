![luatomlPic](https://github.com/knd/luatoml/raw/master/luatoml.png)

## Why TOML?

Think of XML, JSON or YAML, **TOML** has its own advantages. See [https://github.com/mojombo/toml](https://github.com/mojombo/toml).

To be brief, **TOML** is readable (like YAML), ease of use (like YAML), fast (like
JSON), and can cut straight to the soul of the problem. I prefer to write more
easy constructs to serve readability as opposed to short, complicated constructs to
save some space and prove smartness: 

> At scale, the skill level of developers reading/writing/maintaining/testing code is going to be a normal distribution around the mean of "not expert." ([link](http://www.quora.com/Go-programming-language/Scala-vs-Go-Could-people-help-compare-contrast-these-on-relative-merits-demerits))

## Usage

### TOML from file
```lua
> require "luatoml"
> file = io.open("data.toml", "r")
> content = file:read("*all")
> luaObject = load(content)
```

### Lua Object to TOML
```lua
> require "luatoml"
> luaString = dump(luaObject)
```

## Test

TODO: Test against [https://github.com/BurntSushi/toml-test](https://github.com/BurntSushi/toml-test).

Small changes for testing.

## License

See [MIT](https://github.com/knd/luatoml/blob/master/LICENSE). Copyright (c) [Khanh Dao](http://www.github.com/knd).

