unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ImgList, StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    StringGrid1: TStringGrid;
    ImageList1: TImageList;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure StringGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;
  buffer: array[0..MAX_PATH-1] of Char;
  Cocher:array[0..100] of Boolean;
  PathAppli: String;
  Bitmap1,Bitmap2,Bitmap3:TBitmap;
  BitmapIcon1,BitmapIcon2,BitmapIcon3:TIcon;
  IconLeft,IconRight,IconWidth,IconTop,IconHeight:Integer;
  RegionCheckBox :array[0..100] of HRGN;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
Fichier: Textfile;
I,II,PosG,PosD:Integer;
ColonneB,ColonneC,Ligne:String;
begin

  //RETERTOIRE COURANT
  GetCurrentDirectory(SizeOf(buffer),Buffer);
  PathAppli := ExtractFilePath(Application.ExeName);


  //MISE EN FORME DU StringGrid
  with StringGrid1 do
  begin
    DefaultRowHeight:=21;
    ColCount :=3;
    FixedCols :=0;
    FixedRows:=1;
    RowCount:=250;
    ColWidths[0]:=50;
    ColWidths[1]:=200;
    ColWidths[2]:=450;
    Cells[0,0]:='X';
    Cells[1,0]:='Information';
    Cells[2,0]:='Values';
  end;

  //CREATION DES IMAGES
  BitmapIcon1:=TIcon.Create;
  ImageList1.GetIcon (0,BitmapIcon1);  //IMAGE CHECKBOX VIDE

  BitmapIcon2:=TIcon.Create;
  ImageList1.GetIcon (3,BitmapIcon2);  //IMAGE CHECKBOX COCHE

  BitmapIcon3:=TIcon.Create;
  ImageList1.GetIcon (4,BitmapIcon3);  //IMAGE CHECKBOX GRISE

  Bitmap1:=TBitmap.Create;
  ImageList1.GetBitmap (2,Bitmap1);    //IMAGE LIGNE FIXE

  Bitmap2:=TBitmap.Create;
  ImageList1.GetBitmap(1,Bitmap2);     //IMAGE DE FOND DU STRINGGRID



  //OUVRE LE FICHIER ET REMPLISSAGE DU StringGrid
  assignfile(fichier ,string(buffer)+'\Fichier.txt');
  Reset(FIchier);

  II:=1;

  while not EOF(fichier) do
    begin
      Readln(fichier, Ligne);


      // Remplissage de la Colonne 1
      posG := 0;
      ColonneB := Copy(Ligne , posG, Length(Ligne)-posG);
      posD := pos(':',ColonneB);
      ColonneB:= Copy(Ligne , posG,posd-1);
      StringGrid1.Cells[1,II]:= Trim(ColonneB);

      // Remplissage de la Colonne 2
      posG := posD+2;
      ColonneC := Copy(Ligne , posG, Length(Ligne)-posG);
      posD :=length(Ligne);
      ColonneC:= Copy(Ligne , posG,posd-1);
      StringGrid1.Cells[2,II]:= ColonneC;

      if ColonneB <>'' then II:=II+1;
    end;
   CloseFile(FIchier);

   StringGrid1.RowCount :=II;
   for I:=0 to II do Cocher[I]:=False;

end;


procedure TForm1.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
TypeIcon:TIcon;
begin

   with StringGrid1 do
    begin
      Canvas.Brush.Style:=bsClear;

      If ARow=0 then  //AFFICHE LA PREMIERE LIGNE
      begin
        canvas.Font.Color  :=ClWhite;
        Canvas.Font.Size :=10;
        Canvas.Font.Name:='Arial';
        Canvas.Font.Style :=[fsBold];
        Canvas.StretchDraw(Rect,Bitmap1);

        DrawText(Canvas.Handle, PChar(Cells[ACol ,ARow]), -1, Rect ,
        DT_CENTER or DT_NOPREFIX or DT_VCENTER or DT_SINGLELINE  );
      end
      else
      begin

        //POSITION LE L'IMAGE DU CHECKBOX
        Rect.Left:= StringGrid1.ColWidths[0] div 2;
        Rect.Left:=Rect.Left - (16 div 2);

        Rect.Top := Rect.Top + (DefaultRowHeight div 2);
        Rect.Top := Rect.Top  - (16 div 2);


        //CREATION DE LA REGION DU CHECKBOX
        IconLeft:= Rect.Left ;
        IconWidth:= (IconLeft + 16 ); //16 PIXELS DE LARGE
        IconTop:=  Rect.Top ;
        IconHeight:= IconTop +16; //16 PIXEL DE HAUT

        RegionCheckBox[Arow]:= CreateRectRgn(IconLeft,IconTop,IconWidth,IconHeight);

        //SI LA COLONNE 2 EST VIDE L'IMAGE SERA LE CHECKBOX GRISE
        If Cells[2,Arow]<> '' then TypeIcon:=BitmapIcon1 else
        TypeIcon:=BitmapIcon3;

        If (ACol=0) then
        begin
          //SI Cocher[ARow]=1 ALORS L'IMAGE SERA LE CHECKBOX COCHE SINON BitampIcon3 (VIDE OU GRISE)
          if (Cocher[ARow]=True) and (Cells[2,Arow]<>'') then Canvas.StretchDraw(Rect,BitmapIcon2) else
          Canvas.StretchDraw(Rect,TypeIcon);
        end;

        end;

        //LIGNE SELECTIONNEE
        if (gdFocused in State) then
          begin
            Rect.Left:= - StringGrid1.ColWidths[0] div 2;
            Rect.Left:=Rect.Left - (16 div 2);;

            Rect.Top := Rect.Top - (DefaultRowHeight div 2);
            Rect.Top := Rect.Top  + (16 div 2);

            Canvas.Font.Color  :=clYellow ;
            Canvas.Font.Style :=[];

            If (ACol=0)then
            begin
              Canvas.StretchDraw(Rect,Bitmap2);

              Rect.Left:= StringGrid1.ColWidths[0] div 2;
              Rect.Left:=Rect.Left - (16 div 2);

              Rect.Top := Rect.Top + (DefaultRowHeight div 2);
              Rect.Top := Rect.Top  - (16 div 2);

            //SI Cocher[ARow]=1 ALORS L'IMAGE SERA LE CHECKBOX COCHE SINON BitampIcon3 (VIDE OU GRISE)
            if (Cocher[ARow]=True) and (Cells[2,Arow]<>'') then Canvas.StretchDraw(Rect,BitmapIcon2) else
            Canvas.StretchDraw(Rect,TypeIcon);
            end;
         end;
    end;

  //AFFICHE LE LIGNE COCHE DANS LE LABEL
  if Cocher[StringGrid1.Row]=True then
  Label1.Caption :=StringGrid1.Cells[2,StringGrid1.Row] else Label1.Caption:='' ;
end;


procedure TForm1.StringGrid1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
  var
  MX,MY:Integer;
  Coord: TGridCoord;
begin

    Coord:= StringGrid1.MouseCoord(X,Y);

    //SI LA LIGNE EST > A ZERO ET LA COLONNE EST = ZER0 ALORS FOCUS SUR LA LIGNE
    If (Coord.Y >0) and (Coord.X =0) then StringGrid1.Row :=Coord.Y;

    //POSITONS X,Y DE LA SOURIS SUR LE StringGrid
    MX:=Mouse.CursorPos.X - StringGrid1.ClientOrigin.X;
    MY:=Mouse.CursorPos.Y - StringGrid1.ClientOrigin.Y;


    //SI LES COORDONNEES DE LA SOURIS SONT EGALES AUX COORDONEES DE LA REGION DE RegionCheckBox[Coord.Y]
    //ALORS LE CURSEUR DE LA SOURIS CHANGE
    if PtInRegion(RegionCheckBox[Coord.Y],MX, MY)= True then
    StringGrid1.Cursor := crHandPoint  else StringGrid1.Cursor := crDefault;

end;

procedure TForm1.StringGrid1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  //CHECKBOX True OU False
  If StringGrid1.Cursor = crHandPoint then

  if (Cocher[StringGrid1.Row]=False) and (StringGrid1.Cells[2,StringGrid1.Row]<>'') then
  Cocher[StringGrid1.Row]:=True else Cocher[StringGrid1.Row]:=False;

  StringGrid1.Refresh;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
StringGrid1.DefaultRowHeight :=StrToInt(ComboBox1.Text);
StringGrid1.SetFocus;
end;

end.
