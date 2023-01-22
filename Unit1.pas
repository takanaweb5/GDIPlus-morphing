unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, GDIPOBJ, GDIPAPI;

type
  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    procedure PaintBox1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FGPBitmap: array[1..2] of TGPBitmap;
    FCounter: Integer;
  public
    { Public 宣言 }
  end;

const
  FILE1 = 'z:\file1.jpg';
  FILE2 = 'z:\file2.jpg';
  WAITTIME = 10; //1回ごとのウェイトタイム（ミリ秒）
  TIMES = 100;   //変身までに何回描画するか

var
  Form1: TForm1;

implementation

{$R *.dfm}

////*****************************************************************************
////[概要] ログファイルにログを書込む
////[引数] 書込む文字列，ファイル名
////[戻値] なし
////*****************************************************************************
//procedure OutputDebugStr(str: string; strFileName: string = '');
//const
//  FileName = 'Z:\Debug.log';
//var
//  FLog: TextFile;
//begin
//  if strFileName = '' then strFileName := FileName;
//  AssignFile(FLog, strFileName);
//  try
//    if FileExists(strFileName) then Append(FLog)  // ファイルの末尾に追加
//                               else Rewrite(FLog);// 新しいファイルを作成し開く
//    Writeln(FLog, str);
//  finally
//    CloseFile(FLog);
//  end;
//end;
//
////*****************************************************************************
////[概要] ログファイルにログを書込む
////[引数] 書込む文字列，ファイル名
////[戻値] なし
////*****************************************************************************
//procedure OutputDebugLog(str: string; strFileName: string = '');
//var
//  ST: SYSTEMTIME;
//begin
//  GetLocalTime(ST);
//  str := Format('%.2d:%.2d:%.2d.%.3d',
//         [ST.wHour, ST.wMinute, ST.wSecond, ST.wMilliseconds])
//          + ' : '+ str;
//  OutputDebugStr(str, strFileName);
//end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FGPBitmap[1] := TGPBitmap.Create(FILE1);
  FGPBitmap[2] := TGPBitmap.Create(FILE2);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FGPBitmap[1]);
  FreeAndNil(FGPBitmap[2]);
end;

procedure TForm1.PaintBox1Click(Sender: TObject);
begin
  for var i := 0 to TIMES - 1 do begin
    FCounter := i;
    PaintBox1.Invalidate;
    Application.ProcessMessages;
    Sleep(WAITTIME);
  end;
  var swap := FGPBitmap[1];
  FGPBitmap[1] := FGPBitmap[2];
  FGPBitmap[2] := swap;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  gcanvas: TGPGraphics;
  cm: TColorMatrix;
  ia: TGPImageAttributes;
begin
  var w := FGPBitmap[1].GetWidth;
  var h := FGPBitmap[1].GetHeight;

  ia := TGPImageAttributes.Create;

  gcanvas := TGPGraphics.Create(PaintBox1.Canvas.Handle);
  //gcanvas.SetCompositingQuality(CompositingQualityGammaCorrected);

  fillChar(cm,SizeOf(TColorMatrix),#0);
  for var i := 0 to 4 do cm[i,i] := 1.0;

  cm[3,3] := FCounter / TIMES;
//  OutputDebugLog(cm[3,3].tostring);

  ia.SetColorMatrix(cm);
  gcanvas.DrawImage(FGPBitmap[1],
                    MakeRect(0, 0, w, h),
                    0, 0,
                    w, h,
                    UnitPixel,
                    ia);

  cm[3,3] := 1.0 - cm[3,3];
  ia.SetColorMatrix(cm);
  gcanvas.DrawImage(FGPBitmap[2],
                    MakeRect(0, 0, w, h),
                    0, 0,
                    w, h,
                    UnitPixel,
                    ia);

  FreeAndNil(gcanvas);
  FreeAndNil(ia);
end;

end.
