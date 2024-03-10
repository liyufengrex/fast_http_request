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
import { HttpRequest } from '@rex/fast_http/Index';
```
#### 2. 定义接口请求返回的数据模型

举个栗子🌰：
```ts
/// 接口返回结果通用模型
interface CommonResponseModel<T> {
  code: number
  data: T
}

/// 接口返回结果业务模型, 用于测试返回的 response 转 业务模型
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
#### 3. 声明网络请求，指定要求返回的泛型类型
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

#### 4. 发送网络请求，可直接得到指定类型的对象
```ts
try {
      const response : CommonResponseModel<ResponseModel> = await request.execute()
      let responseTxt = JSON.stringify(response);
      console.log(`response == ${responseTxt}`)
    } catch (e) {
      let errorMessage = JSON.stringify(e);
      console.log(`error == ${errorMessage}`)
    }
```


