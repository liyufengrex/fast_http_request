import { HttpRequest, HttpResponse } from '@rex/fast_http/Index';
import { CommonFillButton, CommonMainTitle, CommonSubTitle, FastLoadingDialog, FastToast } from '@rex/fast_ui/Index';
import { http } from '@kit.NetworkKit'
import { BaseRequestOption } from '@rex/fast_http/src/main/ets/base/HttpRequestOption';

@Extend(Column)
function ColumnStyle() {
  .width('100%')
  .height('100%')
  .borderRadius(24)
  .backgroundColor(Color.White)
  .padding('15vp')
}

@Entry
@Component
struct Index {
  // 记录显示请求的返回结果
  @State responseTxt: string = ''
  request: GetRequest = new GetRequest();
  loadingDialog = new CustomDialogController(
    {
      builder: FastLoadingDialog(),
      alignment: DialogAlignment.Center,
      customStyle: true,
      maskColor: Color.Transparent,
    }
  )

  build() {
    Navigation() {
      Column({ space: '5vp' }) {
        CommonMainTitle({
          text: `请求类型：${this.request.method}`
        })
        CommonMainTitle({
          text: `请求域名：${this.request.domain}`
        })
        CommonMainTitle({
          text: `请求路径：${this.request.path}`
        })
        CommonMainTitle({
          text: `GET数据：${JSON.stringify(this.request.getQuery)}`
        })
        Blank().height('15.vp')
        CommonFillButton({
          text: '发送请求',
          event: () => {
            this.requestMock(new GetRequest())
          }
        })
        Blank().height('30.vp')
        CommonMainTitle({
          text: `返回的请求结果：`
        })
        Blank().height('15.vp')
        CommonSubTitle({
          text: this.responseTxt,
        })
      }
      .alignItems(HorizontalAlign.Start)
      .ColumnStyle()
    }
    .title('网络请求示例')
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .padding({ left: 12, right: 12, bottom: 4, top: 4 })
    .height('100%')
    .width('100%')
    .backgroundColor('#F3F4F5')
  }

  // 发送网络请求
  async requestMock(request: HttpRequest<object>): Promise<void> {
    this.loadingDialog.open()
    try {
      const response = await request.execute()
      this.responseTxt = JSON.stringify(response);
    } catch (e) {
      let errorMessage = JSON.stringify(e);
      this.responseTxt = errorMessage;
      FastToast.shortToast(errorMessage)
    } finally {
      this.loadingDialog.close()
    }
  }
}

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
