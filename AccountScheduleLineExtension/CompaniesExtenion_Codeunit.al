pageextension 50122 AllowedCompaniesExt extends "Allowed Companies"
{
    layout
    {

    }

    actions
    {
    }
    procedure GetSelectionFilter(): Text
    var
        Comp: Record Company;
        SelectionFilterManagementComp: Codeunit SelectionFilterMngtCompany;
    begin
        CurrPage.SetSelectionFilter(Comp);
        exit(SelectionFilterManagementComp.GetSelectionFilterForCompany(comp));
    end;
}

codeunit 50123 SelectionFilterMngtCompany
{
    trigger OnRun()
    begin
    end;

    procedure GetSelectionFilter(var TempRecRef: RecordRef; SelectionFieldID: Integer): Text
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FirstRecRef: Text;
        LastRecRef: Text;
        SelectionFilter: Text;
        SavePos: Text;
        TempRecRefCount: Integer;
        More: Boolean;
    begin
        if TempRecRef.IsTemporary then begin
            RecRef := TempRecRef.Duplicate;
            RecRef.Reset;
        end else
            RecRef.Open(TempRecRef.Number);

        TempRecRefCount := TempRecRef.Count;
        if TempRecRefCount > 0 then begin
            TempRecRef.Ascending(true);
            TempRecRef.Find('-');
            while TempRecRefCount > 0 do begin
                TempRecRefCount := TempRecRefCount - 1;
                RecRef.SetPosition(TempRecRef.GetPosition);
                RecRef.Find;
                FieldRef := RecRef.Field(SelectionFieldID);
                FirstRecRef := Format(FieldRef.Value);
                LastRecRef := FirstRecRef;
                More := TempRecRefCount > 0;
                while More do
                    if RecRef.Next = 0 then
                        More := false
                    else begin
                        SavePos := TempRecRef.GetPosition;
                        TempRecRef.SetPosition(RecRef.GetPosition);
                        if not TempRecRef.Find then begin
                            More := false;
                            TempRecRef.SetPosition(SavePos);
                        end else begin
                            FieldRef := RecRef.Field(SelectionFieldID);
                            LastRecRef := Format(FieldRef.Value);
                            TempRecRefCount := TempRecRefCount - 1;
                            if TempRecRefCount = 0 then
                                More := false;
                        end;
                    end;
                if SelectionFilter <> '' then
                    SelectionFilter := SelectionFilter + '|';
                if FirstRecRef = LastRecRef then
                    SelectionFilter := SelectionFilter + AddQuotes(FirstRecRef)
                else
                    SelectionFilter := SelectionFilter + AddQuotes(FirstRecRef) + '..' + AddQuotes(LastRecRef);
                if TempRecRefCount > 0 then
                    TempRecRef.Next;
            end;
            exit(SelectionFilter);
        end;
    end;

    procedure AddQuotes(inString: Text[1024]): Text
    begin
        if DelChr(inString, '=', ' &|()*@<>=.') = inString then
            exit(inString);
        exit('''' + inString + '''');
    end;


    procedure GetSelectionFilterForCompany(var Comp: Record Company): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Comp);
        exit(GetSelectionFilter(RecRef, Comp.FieldNo(Name)));
    end;
}