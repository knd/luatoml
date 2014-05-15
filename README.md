![luatomlPic](https://github.com/knd/luatoml/raw/master/luatoml.png)

## License

See [MIT](https://github.com/knd/luatoml/blob/master/LICENSE). Copyright (c) [Khanh Dao](http://www.github.com/knd).

### Why TOML:

Think of XML or JSON, TOML has its own advantage. See [https://github.com/mojombo/toml](https://github.com/mojombo/toml).

## Usage

### TOML from file
```lua
> require "luatoml"
> file = io.open("data.toml", "r")
> content = file:read("*all")
> luaObject = load(content)
```

## Test

TODO: Test against [https://github.com/BurntSushi/toml-test](https://github.com/BurntSushi/toml-test).

