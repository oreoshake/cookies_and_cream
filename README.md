# SecureCookies

SecureCookies is an extract of the cookie functionality from [secure_headers](https://github.com/twitter/secure_headers). Rails has good header support but the cookie support is still lacking. Maybe one day this functionality will be added to rails core.

## Configuration

These can be defined in the form of a boolean, or as a Hash for more refined configuration.

__Note__: Regardless of the configuration specified, Secure cookies are only enabled for HTTPS requests.

#### Defaults

By default, all cookies will get both `Secure`, `HttpOnly`, and `SameSite=Lax`.

```ruby
config.cookies = {
  secure: true, # defaults to true but will be a no op on non-HTTPS requests
  httponly: true, # defaults to true
  samesite: {  # defaults to set `SameSite=Lax`
    lax: true
  }
}
```

#### Boolean-based configuration

Boolean-based configuration is intended to globally enable or disable a specific cookie attribute. *Note: As of 4.0, you must use OPT_OUT rather than false to opt out of the defaults.*

```ruby
config.cookies = {
  secure: true, # mark all cookies as Secure
  httponly: OPT_OUT, # do not mark any cookies as HttpOnly
}
```

#### Hash-based configuration

Hash-based configuration allows for fine-grained control.

```ruby
config.cookies = {
  secure: { except: ['_guest'] }, # mark all but the `_guest` cookie as Secure
  httponly: { only: ['_rails_session'] }, # only mark the `_rails_session` cookie as HttpOnly
}
```

#### SameSite cookie configuration

SameSite cookies permit either `Strict` or `Lax` enforcement mode options.

```ruby
config.cookies = {
  samesite: {
    strict: true # mark all cookies as SameSite=Strict
  }
}
```

`Strict` and `Lax` enforcement modes can also be specified using a Hash.

```ruby
config.cookies = {
  samesite: {
    strict: { only: ['_rails_session'] },
    lax: { only: ['_guest'] }
  }
}
```
