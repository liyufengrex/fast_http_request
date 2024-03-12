## fast_http_request

面相对象式网络请求框架

+ 基于 HarmonyOS NEXT 开发
+ 支持将https请求返回的数据直接转换成指定类型的对象

### 安装
```ts
ohpm install @rex/fast_https_request
```

### 使用

#### 1. 导入引用
```ts
import { http } from '@kit.NetworkKit'
import { HttpRequest } from '@rex/fast_https_request/Index';
```
举个栗子🌰：

#### 2. 定义接口请求返回的数据模型

首先，我们定义一个常规返回的通用数据模型：

JSON 结构一般是这样
```ts
{
    'code': 100
    'data': {
        // 里面是具体的业务模型
    }
}
```
对应的模型我们定义如下：

```ts
/// 接口返回结果通用模型, 泛型T为具体的业务模型对象
interface CommonResponseModel<T> {
  code: number
  data: T
}
```
比如：我们新建一个业务模型，名字为 `ResponseModel`，包含字段如下：
```ts
/// 具体的业务模型
class ResponseModel {
  artistsname: string
  name: string
  picurl: string
  url: string

  constructor(
    artistsname: string,
    name: string, picurl:
    string, url: string
  ) {
    this.artistsname = artistsname
    this.name = name
    this.picurl = picurl
    this.url = url
  }
}
```
#### 3. 声明网络请求，通过泛型指定要求返回的对象类型

声明网络请求，指定将返回结果直接转换成上面的业务模型，我们这么做：

##### 如果是GET请求，这么写
```ts
// HttpRequest<T> 将response的返回数据直接转成指定的泛型
class GetRequest extends HttpRequest<CommonResponseModel<ResponseModel>> {
  // 重写请求类型，默认是 POST
  public method: http.RequestMethod = http.RequestMethod.GET;
  // 重写域名domain
  public domain: string = 'https://api.uomg.com';
  // 重写请求路径
  public path: string = '/api/rand.music';
  // GET 传参赋值
  public getQuery: Record<string, string> = {
    'sort': '热歌榜',
    'format': 'json',
  }
}
```

##### 如果是POST请求，这么写
```ts
class PostRequest extends HttpRequest<CommonResponseModel<ResponseModel>> {
  // 重写请求类型，默认是 POST
  public method: http.RequestMethod = http.RequestMethod.POST;
  // 重写域名domain
  public domain: string = 'https://api.uomg.com';
  // 重写请求路径
  public path: string = '/api/comments.163';
  // POST 传参赋值
  public postBody: Record<string, string> = {
    'format': 'json',
  }
}
```

#### 4. 发送网络请求
```ts
try {
      const response : CommonResponseModel<ResponseModel> = await new GetRequest().execute()
      let responseTxt = JSON.stringify(response);
      console.log(`response == ${responseTxt}`)
    } catch (e) {
      let errorMessage = JSON.stringify(e);
      console.log(`error == ${errorMessage}`)
    }
```
使用上面声明的请求 `new GetRequest().excute()` 或者 `new PostRequest().excute()` 获取到的结果为 `CommonResponseModel<ResponseModel>` 对象

```ts
let data : ResponseModel = await new GetRequest().execute().data
```

这样就获取到了我们的业务模型对象


#### 5. 如何打印网络日志
在继承 HttpRequest 时选择重写内部三方方法，可用于分别打印 request、response、httpError

```ts
class PostRequest extends HttpRequest<T> {
  ....省略具体的请求
  
  // 重写该方法打印 request
  protected onRequestChain(request: BaseRequestOption): void {
    console.log(`fast_http_request >>> url : ${this.requestUrl()}`)
    if (request.postBody != null){
      console.log(`fast_http_request >>> POST Parmas : ${JSON.stringify(request.postBody)}`)
    }
  }

  // 重写该方法打印 response
  protected onResponseChain(response: HttpResponse): void {
    console.log(`fast_http_request >>> response : ${JSON.stringify(response)}`)
  }

  // 重写该方法打印 http error
  protected onErrorChain(error: Error): void {
    console.log(`fast_http_request >>> error : ${JSON.stringify(error)}`)
  }
}

```

#### 6. 如何在工程中，统一管理，进行复用

我们可以按照域名定义一个通用的 `CommonRequest`，例如：

```ts
class CommonRequest<T> extends HttpRequest<CommonResponseModel<T>> {
  // 重写域名domain
  public domain: string = 'https://api.uomg.com';
  
  ///这里自己把log加上，统一打印请求日志
}
```

遇到具体的业务时

假设我们业务接口返回的的数据，定义模型名称为 `BusinessModel`

```ts
class BusinessModel {
    /// 具体的业务字段
}
```

所有的业务请求，我们可以通过继承 `CommonRequest`，创建具体的业务请求，指定泛型即可

```ts
class BusinessRequest extends CommonRequest<BusinessModel> {
    // Model 是请求参数，这里我定义为 Record 类型，按照自己的需要也可以定义为其他
    constructor(requestParams: Record<string, Object>){
        this.postBody = requestParams;
    }
    
    // 重写请求路径
  public path: string = '具体的url';
}
```

如上便完成了一个业务请求的封装, 通过 new 即可使用

```ts
let requestParams = {
    'pageIndex': '1',
    'keywords': 'rex',
}

let request = new BusinessRequest(requestParams);

request.excute().then((data)=>{
    // 这里获取的 data 类型为 CommonResponseModel<BusinessModel>
})
```



