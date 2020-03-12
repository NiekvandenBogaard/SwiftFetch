# SwiftFetch

SwiftPackage to make simple network requests.

### Documentation

**Installation**

- Add SwiftFetch as a SwiftPackage depencency<br>
[Adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

- When searching for packages in xcode enter:<br>
`https://github.com/NiekvandenBogaard/SwiftFetch.git`

**Import**

```swift
import SwiftFetch
```

**Fetch**

```swift
fetch(URL(string: "https://google.com")!).response { (result, response) in
    switch result {
    case .success(let data): // note response data is optional
        print("success")
    case .failure(let error):
        print("error", error)
    }
}
```

**FetchOptions**
Optional values to pass to the fetch function.

```swift
fetch(URL(string: "https://google.com")!, method: .post, query: ["limit": "10"], headers: ["Accept" : "text/html"]).response { (result, response) in
    switch result {
    case .success(let data): // note response data is optional
        print("success")
    case .failure(let error):
        print("error", error)
    }
}
```

**FetchResponseBody**

```swift
struct User: Codable {

    enum CodingKeys: String, CodingKey {
        case username = "username"
    }

    var username: String
}

fetch(URL(string: "https://google.com")!).response(body: .json(User.self)) { (result, response) in
    switch result {
    case .success(let user):
        print("username", user.username)
    case .failure(let error):
        print("error", error)
    }
}
```
- `.data()` Raw data response body.
- `.text()` Text response body.
- `.json(_:)` Json response body. (parameter is `Decodable` type) (result will be the given type)
- `.json()` Json response body. (result will be `[String: Any]`)
- `.urlEncoded()` Urlencoded response body. (result will be `[String: String?]`)

**FetchRequestBody**

```swift
let user = User(username: "NiekBogaard")

fetch(URL(string: "https://google.com")!, method: .post, body: .json(user)).response(body: .json(User.self)) { (result, response) in
    switch result {
    case .success(let user):
        print("username", user.username)
    case .failure(let error):
        print("error", error)
    }
}
```
- `.data()` Raw data request body.
- `.text()` Text request body.
- `.json(_:)` Json request body. (parameter is a `Encodable` instance)
- `.json(_:)` Json request body. (parameter is `[String: Any]`)
- `.urlEncoded(_:)` Urlencoded request body. (parameter is `[String: String?]`)
