Codeunit 59326 "Get Details as Json"
{

    trigger OnRun()
    begin
    end;

    procedure GetAsJson(var ProductionOrder: Record "Production Order"): Text
    var
        text: label '{"Start": ╩20190423080000╦, "End": ╩201904251700╦, "Current": ╩201904241200╦, "Details" : [{End: ╩20190423090000╦, Color : ╩grey╦, InnerText: ╩Deventer╦, "ExtendedText": ╩Load 5 Pallets╦, "OnClick":╦343945╦}, {End: ╩20190423120000╦, Color : ╩grey╦, InnerText: ╩Driving╦, ExtendedText: ╩345 KMS╦, OnClick:╦343946╦}]}';
    begin
        exit(GetStartEndAndCurrent(ProductionOrder) + GetDetailsPerRouting(ProductionOrder) + GetClose);
    end;

    local procedure GetStartEndAndCurrent(var ProductionOrder: Record "Production Order"): Text
    begin
        exit('{' +
          '"start":' + FormatDateTime(CreateDatetime(20181231D, 060000T)) + ',' +
          '"end":' + FormatDateTime(CreateDatetime(20181231D, 220000T)) + ',' +
          '"current":' + FormatDateTime(CreateDatetime(20181231D, 100000T)) + ',' +
          '"details":[');
    end;

    local procedure GetDetailsPerRouting(var ProductionOrder: Record "Production Order") ReturnValue: Text
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        ProdOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        if ProdOrderRoutingLine.FindSet then repeat
          if ReturnValue <> '' then
            ReturnValue += ',';
          ReturnValue += GetJsonFromRouting(ProdOrderRoutingLine);
        until ProdOrderRoutingLine.Next = 0;
    end;

    local procedure GetJsonFromRouting(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"): Text
    begin
        with ProdOrderRoutingLine do
          exit(
            '{' +
            '"start":' + FormatDateTime("Starting Date-Time") + ',' +
            '"end":' + FormatDateTime("Ending Date-Time") + ',' +
            '"color":"' + GetColor(ProdOrderRoutingLine) + '",' +
            '"innerText":"' + ProdOrderRoutingLine.Description + '",' +
            '"extendedText":"' + ProdOrderRoutingLine."Work Center No." + '",' +
            '"onClick":"' + 'FooBar' + '"' +
            '}');
    end;

    local procedure GetClose(): Text
    begin
        exit(']}');
    end;

    local procedure FormatDateTime(Value: Variant) ReturnValue: Text
    var
        MyDateTime: DateTime;
    begin
        if Value.IsText then
          Evaluate(MyDateTime, Value)
        else
          MyDateTime := Value;
        exit('"' + Format(MyDateTime, 0, 9) + '"');
    end;

    local procedure GetColor(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"): Code[10]
    begin
        with ProdOrderRoutingLine do begin
          if Status = Status::Finished then
            exit('#d3d3d3');
        //    EXIT('#ff0000');                       //* Red
              exit('#e6d9e5');                     //* Pink Grey
        //      EXIT('#c8e7d1');                     //* Light Green
        //      EXIT('#92ccdd');                     //* Light Blue
        //      EXIT('#f5d5fd');                     //* Purple
        //      EXIT('#14b258');                     //* Green
        //      EXIT('#14b258');                     //* Green
        //      EXIT('#f89406');                     //* Orange
        //      EXIT('#e3edfa');                     // Light Grey/Blueish
        //      EXIT('#428b7b');                     //* Windows95 green
        //      EXIT('#eedf3c');                     //* Yellow
        //      EXIT('#69858e');                     // Dark Grey/Blueish
        end;
    end;
}

Page 59326 "Production Order Entity"
{
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'productionOrder';
    EntitySetName = 'productionOrders';
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = Id;
    PageType = API;
    APIPublisher = 'GlobalMediator';
    APIVersion = 'v1.0';
    APIGroup = 'MetaUI';
    Caption = 'productionOrder';
    SourceTable = "Production Order";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(status;Status)
                {
                    ApplicationArea = Basic;
                }
                field(no;"No.")
                {
                    ApplicationArea = Basic;
                }
                field(description;Description)
                {
                    ApplicationArea = Basic;
                }
                field(planningDetails;GetDetailsasJson.GetAsJson(Rec))
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    var
        GetDetailsasJson: Codeunit "Get Details as Json";
}

tableextension 59326 "Production Order (API)" extends "Production Order"
{
    fields
    {
        field(59326; Id; Guid) {}
    }
    
trigger OnInsert()
begin
    Id := CreateGuid()    
end;

trigger OnModify()
begin
    if IsNullGuid(Id) then
        Id := CreateGuid()    
end;
}