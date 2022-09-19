pageextension 50140 AccountSchedulesExt extends "Account Schedule"
{
    layout
    {

    }
    actions
    {
        addafter(EditColumnLayoutSetup)
        {
            action(CopyAccountScheduleLines)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Copy account schedule lines';
                Image = Copy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;
                ToolTip = 'Copy selected account schedule lines and paste at bottom.';

                trigger OnAction()
                var
                    AccScheduleLine: Record "Acc. Schedule Line";
                    lastAccSchedLine: Record "Acc. Schedule Line";
                    AccSchedLineNo: Integer;
                    rowNo: Integer;
                    strRowNo: Code[10];
                begin
                    SetupAccSchedLine(AccScheduleLine);
                    lastAccSchedLine.SetFilter("Schedule Name", AccScheduleLine."Schedule Name");
                    if lastAccSchedLine.Find('+')
                    then begin
                        AccSchedLineNo := lastAccSchedLine."Line No.";
                        evaluate(rowNo, lastAccSchedLine."Row No.")
                    end;

                    CurrPage.SetSelectionFilter(AccScheduleLine);
                    if AccScheduleLine.FindSet then
                        repeat
                            Rec.Init;
                            AccSchedLineNo := AccSchedLineNo + 10000;
                            Rec."Line No." := AccSchedLineNo;
                            Rec."Schedule Name" := AccScheduleLine."Schedule Name";
                            Rec."Totaling Type" := AccScheduleLine."Totaling Type";
                            rec.Totaling := AccScheduleLine.Totaling;
                            Rec."Row Type" := AccScheduleLine."Row Type";
                            rec."Amount Type" := AccScheduleLine."Amount Type";
                            rec."Show Opposite Sign" := AccScheduleLine."Show Opposite Sign";
                            Rec.Show := AccScheduleLine.Show;
                            rec.Indentation := AccScheduleLine.Indentation;
                            rec.Bold := AccScheduleLine.Bold;
                            rec.Italic := AccScheduleLine.Italic;
                            rec.Underline := AccScheduleLine.Underline;
                            rec."New Page" := AccScheduleLine."New Page";
                            rec."Business Unit Filter" := AccScheduleLine."Business Unit Filter";
                            rec."Cash Flow Forecast Filter" := AccScheduleLine."Cash Flow Forecast Filter";
                            rec."Cost Budget Filter" := AccScheduleLine."Cost Budget Filter";
                            rec."Cost Center Filter" := AccScheduleLine."Cost Center Filter";
                            rec."Cost Center Totaling" := AccScheduleLine."Cost Center Totaling";
                            rec."Cost Object Filter" := AccScheduleLine."Cost Object Filter";
                            rec."Cost Object Totaling" := AccScheduleLine."Cost Object Totaling";
                            rec."Date Filter" := AccScheduleLine."Date Filter";
                            rec.Description := AccScheduleLine.Description;
                            rec."Dimension 1 Filter" := AccScheduleLine."Dimension 1 Filter";
                            rec."Dimension 1 Totaling" := AccScheduleLine."Dimension 1 Totaling";
                            rec."Dimension 2 Filter" := AccScheduleLine."Dimension 2 Filter";
                            rec."Dimension 2 Totaling" := AccScheduleLine."Dimension 2 Totaling";
                            rec."Dimension 3 Filter" := AccScheduleLine."Dimension 3 Filter";
                            rec."Dimension 3 Totaling" := AccScheduleLine."Dimension 3 Totaling";
                            rec."Dimension 4 Filter" := AccScheduleLine."Dimension 4 Filter";
                            rec."Dimension 4 Totaling" := AccScheduleLine."Dimension 4 Totaling";
                            rec."Double Underline" := AccScheduleLine."Double Underline";
                            rec."G/L Budget Filter" := AccScheduleLine."G/L Budget Filter";

                            strRowNo := Format(rowNo + 10);
                            rowNo := rowNo + 10;


                            evaluate(rec."Row No.", strRowNo);
                            Rec.Description := AccScheduleLine.Description;
                            rec.Insert();
                        until AccScheduleLine.Next = 0;
                    //CurrPage.Update();
                end;
            }
        }
    }
}

pageextension 50141 "Excel Account Schedule Ext" extends "Account Schedule Names"
{
    layout
    {
    }
    actions
    {
        addafter(CopyAccountSchedule)
        {
            action(importFromExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import account schedule from excel';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;
                ToolTip = 'Import account schedule name and lines from excel.';

                trigger OnAction()
                begin
                    ImportExcel();
                end;
            }
        }
        addafter(importFromExcel)
        {
            action(exportToExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Export Account Schedule to excel';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;
                ToolTip = 'Export account schedule name and lines to excel';

                trigger OnAction()
                begin
                    ExportExcel();
                end;
            }
        }
        addafter(CopyAccountSchedule)
        {
            action(CopyAccountScheduleCompany)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Copy Account Schedule to other Company';
                Image = Copy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;
                ToolTip = 'Create a copy of the current account schedule to other company.';

                trigger OnAction()
                var
                    AccScheduleName: Record "Acc. Schedule Name";
                begin
                    CurrPage.SetSelectionFilter(AccScheduleName);
                    REPORT.RunModal(REPORT::"Copy Account Schedule Company", true, true, AccScheduleName);
                end;
            }
        }
    }
    var

        Rec_ExcelBuffer: Record "Excel Buffer";
        Rows: Integer;
        Columns: Integer;
        Fileuploaded: Boolean;
        UploadIntoStream: InStream;
        FileName: Text;
        Sheetname: Text;
        UploadResult: Boolean;
        DialogCaption: Text;
        NameF: Text;
        NVInStream: InStream;
        RecAccSched: Record "Acc. Schedule Name";
        RecAccSchedLine: Record "Acc. Schedule Line";
        RowNo: Integer;
        TxtDate: Text;
        DocumentDate: Date;
        LineNo: Integer;

    local procedure ImportExcel()
    begin
        Rec_ExcelBuffer.DeleteAll;
        Rows := 0;
        Columns := 0;
        DialogCaption := 'Select File to upload';
        UploadResult := UploadIntoStream(DialogCaption, '', '', NameF, NVInStream);
        //        If NameF <> '' then
        Sheetname := Rec_ExcelBuffer.SelectSheetsNameStream(NVInStream);
        //        else
        //            exit;
        Rec_ExcelBuffer.Reset();
        Rec_ExcelBuffer.OpenBookStream(NVInStream, Sheetname);

        Rec_ExcelBuffer.ReadSheet();
        Commit();

        //      Message('sheet %1', Sheetname);
        RecAccSched.Name := Sheetname;
        RecAccSched.Description := '';
        RecAccSched."Default Column Layout" := 'PERIODS';
        RecAccSched."Analysis View Name" := '';
        RecAccSched."Financial Period Description" := '';
        RecAccSched.Insert(true);


        //finding total number of Rows to Import

        Rec_ExcelBuffer.Reset();

        Rec_ExcelBuffer.SetRange("Column No.", 1);

        If Rec_ExcelBuffer.FindFirst() then
            repeat

                Rows := Rows + 1;

            until Rec_ExcelBuffer.Next() = 0;

        //        Message('No. of rows %1', Rows);



        //Finding total number of columns to import

        Rec_ExcelBuffer.Reset();

        Rec_ExcelBuffer.SetRange("Row No.", 1);

        if Rec_ExcelBuffer.FindFirst() then
            repeat

                Columns := Columns + 1;

            until Rec_ExcelBuffer.Next() = 0;




        //Function to Get the last line number in Job Journal

        LineNo := 10000;



        for RowNo := 1 to Rows do begin

            RecAccSchedLine.Init();
            RecAccSchedLine."Line No." := LineNo;
            RecAccSchedLine."Schedule Name" := Sheetname;
            RecAccSchedLine."Row No." := GetValueAtIndex(RowNo, 1);
            RecAccSchedLine.Description := GetValueAtIndex(RowNo, 2);


            Evaluate(RecAccSchedLine."Totaling Type", GetValueAtIndex(RowNo, 3));
            RecAccSchedLine.Validate(RecAccSchedLine."Totaling Type");

            RecAccSchedLine.Totaling := GetValueAtIndex(RowNo, 4);

            Evaluate(RecAccSchedLine."Row Type", GetValueAtIndex(RowNo, 5));
            RecAccSchedLine.Validate(RecAccSchedLine."Row Type");

            Evaluate(RecAccSchedLine."Amount Type", GetValueAtIndex(RowNo, 6));
            RecAccSchedLine.Validate(RecAccSchedLine."Amount Type");

            Evaluate(RecAccSchedLine."Show Opposite Sign", GetValueAtIndex(RowNo, 7));
            RecAccSchedLine.Validate(RecAccSchedLine."Show Opposite Sign");

            Evaluate(RecAccSchedLine.Show, GetValueAtIndex(RowNo, 8));
            RecAccSchedLine.Validate(RecAccSchedLine.Show);

            Evaluate(RecAccSchedLine.Bold, GetValueAtIndex(RowNo, 9));
            RecAccSchedLine.Validate(RecAccSchedLine.Bold);


            Evaluate(RecAccSchedLine.Italic, GetValueAtIndex(RowNo, 10));
            RecAccSchedLine.Validate(RecAccSchedLine.Italic);

            Evaluate(RecAccSchedLine.Underline, GetValueAtIndex(RowNo, 11));
            RecAccSchedLine.Validate(RecAccSchedLine.Underline);

            Evaluate(RecAccSchedLine."New Page", GetValueAtIndex(RowNo, 12));
            RecAccSchedLine.Validate(RecAccSchedLine."New Page");
            RecAccSchedLine.Insert();


            LineNo := LineNo + 10000;
        end;
        Message('Import Completed');
    end;

    local procedure GetValueAtIndex(RowNo: Integer; ColNo: Integer): Text
    var
        Rec_ExcelBuffer: Record "Excel Buffer";
    begin
        Rec_ExcelBuffer.Reset();
        If Rec_ExcelBuffer.Get(RowNo, ColNo) then
            exit(Rec_ExcelBuffer."Cell Value as Text");
    end;

    local procedure ExportExcel()
    var
        TempExcelBuff: Record "Excel Buffer" temporary;
    begin
        FillExcelBuffer(TempExcelBuff);
        OpenExcelFile(TempExcelBuff);
    end;

    local procedure FillExcelBuffer(var TempExcelBuff: Record "Excel Buffer" temporary)
    begin
        RecAccSchedLine.SetFilter("Schedule Name", Rec.Name);
        //      Message(Rec.Name);

        if RecAccSchedLine.FindSet() then
            repeat
                //                Message(RecAccSchedLine.Description);
                TempExcelBuff.NewRow();

                TempExcelBuff.AddColumn(RecAccSchedLine."Row No.", false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
                TempExcelBuff.AddColumn(RecAccSchedLine.Description, false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
                TempExcelBuff.AddColumn(RecAccSchedLine."Totaling Type", false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
                TempExcelBuff.AddColumn(RecAccSchedLine.Totaling, false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
                TempExcelBuff.AddColumn(RecAccSchedLine."Row Type", false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
                TempExcelBuff.AddColumn(RecAccSchedLine."Amount Type", false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
                TempExcelBuff.AddColumn(RecAccSchedLine."Show Opposite Sign", false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
                TempExcelBuff.AddColumn(RecAccSchedLine.Show, false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
                TempExcelBuff.AddColumn(RecAccSchedLine.Bold, false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
                TempExcelBuff.AddColumn(RecAccSchedLine.Italic, false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
                TempExcelBuff.AddColumn(RecAccSchedLine.Underline, false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
                TempExcelBuff.AddColumn(RecAccSchedLine."New Page", false, '', false, false, false, '', TempExcelBuff."Cell Type"::Text);
            until RecAccSchedLine.Next() = 0;
    end;

    local procedure OpenExcelFile(var TempExcelBuff: Record "Excel Buffer" temporary)
    begin
        // TempExcelBuff.CreateBook('AccountSchedule',Rec.Name);
        TempExcelBuff.CreateNewBook(Rec.Name);
        //FillExcelBuffer(TempExcelBuff);
        TempExcelBuff.WriteSheet('', CompanyName(), UserId());
        TempExcelBuff.CloseBook();
        TempExcelBuff.OpenExcel();
    end;
}


report 50141 "Copy Account Schedule Company"
{
    Caption = 'Copy Account Schedule to Company';
    ProcessingOnly = true;

    dataset
    {
        dataitem(SourceAccScheduleName; "Acc. Schedule Name")
        {
            DataItemTableView = SORTING(Name) ORDER(Ascending);

            trigger OnAfterGetRecord()
            var
                SourceAccScheduleLine: Record "Acc. Schedule Line";
                AccScheduleName: Record "Acc. Schedule Name";
                ColumnLayoutName: Record "Column Layout Name";
                SrcColLayout: Record "Column Layout";
                AllowedCompanies: Record Company;
                arrays: list of [text];
                i: Integer;
            begin



                AllowedCompanies.SetFilter(Name, CompanyDisplayName);
                if AllowedCompanies.FindSet() then
                    repeat
                        //  Message(AllowedCompanies.name);
                        AssertNewAccountScheduleNameNotEmpty();
                        AssertNewAccountScheduleNameNotExisting(AllowedCompanies.Name);
                        AssertSourceAccountScheduleNameNotEmpty();
                        AssertSourceAccountScheduleNameExists(SourceAccScheduleName);
                        if overwrite = true then begin
                            AccScheduleName.Get(CopySourceAccScheduleName);
                            if CopyColumn then begin
                                //                              Message('in col layout copy');
                                //  if CheckColumnLayout(Name, AccScheduleName, AllowedCompanies.Name) = false
                                //  then begin
                                ColumnLayoutName.Get(AccScheduleName."Default Column Layout");
                                CreateColumnLayoutName(AccScheduleName."Default Column Layout", ColumnLayoutName, AllowedCompanies.Name);

                                SrcColLayout.SetRange("Column Layout Name", ColumnLayoutName.Name);
                                if SrcColLayout.FindSet() then
                                    repeat
                                        CreateColumnLayout(AccScheduleName."Default Column Layout", SrcColLayout, allowedcompanies.Name);
                                    until SrcColLayout.Next() = 0;
                                //  end;
                            end;
                            CreateNewAccountScheduleName(NewAccScheduleName, AccScheduleName, AllowedCompanies.Name);
                            if CopyRow then begin
                                //                                Message('in row layout copy');
                                SourceAccScheduleLine.SetRange("Schedule Name", AccScheduleName.Name);
                                if SourceAccScheduleLine.FindSet() then
                                    repeat
                                        CreateNewAccountScheduleLine(NewAccScheduleName, SourceAccScheduleLine, AllowedCompanies.Name);
                                    until SourceAccScheduleLine.Next() = 0;
                            end;
                        end;
                    until AllowedCompanies.Next() = 0;
            end;


            trigger OnPreDataItem()
            begin
                /*AssertNewAccountScheduleNameNotEmpty();
                AssertNewAccountScheduleNameNotExisting(CompanyDisplayName);
                AssertSourceAccountScheduleNameNotEmpty();
                AssertSourceAccountScheduleNameExists(SourceAccScheduleName);*/
                //AssertCompanyNameNotEmpty;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NewAccountScheduleName; NewAccScheduleName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New Account Schedule Name';
                        NotBlank = true;
                        ToolTip = 'Specifies the name of the new account schedule after copying.';
                    }
                    field(SourceAccountScheduleName; CopySourceAccScheduleName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Source Account Schedule Name';
                        Enabled = false;
                        NotBlank = true;
                        ToolTip = 'Specifies the name of the existing account schedule to copy from.';
                    }

                    field(Companies; CompanyDisplayName)
                    {
                        ApplicationArea = All;
                        Caption = 'Company';
                        Editable = false;
                        ToolTip = 'Specifies the database company that you work in. You must sign out and then sign in again for the change to take effect.';

                        trigger OnAssistEdit()
                        var
                            SelectedCompany: Record Company;
                            AllowedCompanies: Page "Allowed Companies";
                            IsSetupInProgress: Boolean;
                        begin
                            AllowedCompanies.Initialize();

                            if SelectedCompany.Get(CompanyName()) then
                                AllowedCompanies.SetRecord(SelectedCompany);

                            AllowedCompanies.LookupMode(true);

                            if AllowedCompanies.RunModal() = ACTION::LookupOK then begin
                                //                                message(AllowedCompanies.getSelectionFilter());// GetRecord(SelectedCompany);
                                //                                Message(SelectedCompany.Name);
                                OnCompanyChange(SelectedCompany.Name, IsSetupInProgress);
                                if IsSetupInProgress then begin
                                    VarCompany := CompanyName();
                                    Message(StrSubstNo(CompanySetUpInProgressMsg, SelectedCompany.Name, PRODUCTNAME.Short()));
                                end else
                                    //                                    if SelectedCompany.FindSet() then
                                    //                                        repeat
                                    //  Message(SelectedCompany.Name);
                                    VarCompany := AllowedCompanies.GetSelectionFilter();

                                //            VarCompany := /*varCompany + ';' +*/ SelectedCompany.Name;
                                //                                        until SelectedCompany.Next() = 0;
                                SetCompanyDisplayName();
                            end;
                        end;
                    }
                    field(CopyColumn; CopyColumn)
                    {
                        ApplicationArea = all;
                        Caption = 'Copy Column Layout?';

                    }
                    field(CopyRow; CopyRow)
                    {
                        ApplicationArea = all;
                        Caption = 'Copy Row Layout?';

                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            AssertSourceAccountScheduleNameOnlyOne(SourceAccScheduleName);

            if SourceAccScheduleName.FindFirst() then begin
                CopySourceAccScheduleName := SourceAccScheduleName.Name;
            end;
            NewAccScheduleName := SourceAccScheduleName.Name;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        if overwrite <> false then
            Message(CopySuccessMsg);
    end;

    var
        VarCompany: Text;
        CompanyDisplayName: Text[250];
        NewAccScheduleName: Code[10];
        CopySuccessMsg: Label 'The new account schedule has been created successfully.';
        MissingSourceErr: Label 'Could not find an account schedule with the specified name to copy from.';
        NewNameExistsErr: Label 'The new account schedule already exists.';
        NewNameMissingErr: Label 'You must specify a name for the new account schedule.';
        CompanyMissingErr: Label 'You must select a Company';
        CopySourceAccScheduleName: Code[10];
        CopySourceNameMissingErr: Label 'You must specify a valid name for the source account schedule to copy from.';
        MultipleSourcesErr: Label 'You can only copy one account schedule at a time.';
        CompanySetUpInProgressMsg: Label 'Company %1 was just created, and we are still setting it up for you.\This may take up to 10 minutes, so take a short break before you begin to use %2.', Comment = '%1 - a company name,%2 - our product name';
        overwrite: Boolean;
        CopyColumn: Boolean;
        CopyRow: Boolean;

    local procedure SetCompanyDisplayName()
    var
        SelectedCompany: Record Company;
        AllowedCompanies: Page "Allowed Companies";
    begin
        //        Message(VarCompany);
        //   SelectedCompany.Name := VarCompany;
        //        SelectedCompany.SetFilter(Name, VarCompany);
        // if SelectedCompany.Find() then begin
        //   Message(VarCompany);
        CompanyDisplayName := VarCompany;// AllowedCompanies.GetCompanyDisplayNameDefaulted(SelectedCompany)
        //end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCompanyChange(NewCompanyName: Text; var IsSetupInProgress: Boolean)
    begin
    end;

    procedure GetNewAccountScheduleName(): Code[10]
    begin
        exit(NewAccScheduleName);
    end;

    local procedure AssertNewAccountScheduleNameNotEmpty()
    begin
        if IsEmptyName(NewAccScheduleName) then
            Error(NewNameMissingErr);
        overwrite := true;
    end;

    local procedure AssertNewAccountScheduleNameNotExisting(company: Text)// overwirte: Boolean
    var
        AccScheduleName: Record "Acc. Schedule Name";
    begin
        AccScheduleName.ChangeCompany(company);
        if AccScheduleName.Get(NewAccScheduleName) then
            overwrite := Dialog.Confirm('The new account schedule already exists in %1. You want to Overwrite it?', true, company);
        // Error(NewNameExistsErr);
    end;

    local procedure AssertCompanyNameNotEmpty()
    begin
        if IsEmptyCompany(CompanyDisplayName) then
            Error(CompanyMissingErr);
    end;

    local procedure CheckColumnLayout(Name: Text[10]; FromAccSched: Record "Acc. Schedule Name"; company: Text) isExist: Boolean
    var
        ColLayoutName: Record "Column Layout Name";

    begin
        //Message(FromAccSched."Default Column Layout");

        ColLayoutName.ChangeCompany(company);
        //Message(FromAccSched."Default Column Layout");
        //ColLayoutName.Name := FromAccSched."Default Column Layout";
        //ColLayoutName.SetFilter(Name, fromAccSched."Default Column Layout");
        if (ColLayoutName.Get(FromAccSched."Default Column Layout"))
            then begin
            isExist := true;
            //CreateColumnLayout()
        end else begin
            isExist := false;
        end;
    end;

    local procedure CreateColumnLayoutName(Name: Text; FromColLayout: Record "Column Layout Name"; Company: Text)
    var
        ColLayoutName: Record "Column Layout Name";
    begin
        ColLayoutName.ChangeCompany(Company);
        if ColLayoutName.Get(Name) then
            exit;
        ColLayoutName.Init();
        ColLayoutName.TransferFields(FromColLayout);
        ColLayoutName.Name := Name;
        ColLayoutName.Insert();
    end;

    local procedure CreateNewAccountScheduleName(NewName: Code[10]; FromAccScheduleName: Record "Acc. Schedule Name"; company: Text)
    var
        AccScheduleName: Record "Acc. Schedule Name";
    begin
        AccScheduleName.ChangeCompany(company);
        if AccScheduleName.Get(NewName) then
            exit;

        AccScheduleName.Init();
        AccScheduleName.TransferFields(FromAccScheduleName);
        AccScheduleName.Name := NewName;
        AccScheduleName.Insert();
    end;

    local procedure CreateColumnLayout(NewName: Text; FromColLayout: Record "Column Layout"; company: text)
    var
        ColLayout: Record "Column Layout";
    begin
        ColLayout.ChangeCompany(company);
        if ColLayout.Get(NewName, FromColLayout."Line No.") then
            exit;

        ColLayout.Init();
        ColLayout.TransferFields(FromColLayout);
        colLayout."Column Layout Name" := NewName;
        ColLayout.Insert();
    end;

    local procedure CreateNewAccountScheduleLine(NewName: Code[10]; FromAccScheduleLine: Record "Acc. Schedule Line"; company: Text)
    var
        AccScheduleLine: Record "Acc. Schedule Line";
    begin
        AccScheduleLine.ChangeCompany(company);
        if AccScheduleLine.Get(NewName, FromAccScheduleLine."Line No.") then
            exit;

        AccScheduleLine.Init();
        AccScheduleLine.TransferFields(FromAccScheduleLine);
        AccScheduleLine."Schedule Name" := NewName;
        AccScheduleLine.Insert();
    end;

    local procedure IsEmptyName(ScheduleName: Code[10]) IsEmpty: Boolean
    begin
        IsEmpty := ScheduleName = '';
    end;

    local procedure IsEmptyCompany(CompanyName: Text[250]) IsEmpty: Boolean
    begin
        IsEmpty := CompanyName = '';
    end;

    local procedure AssertSourceAccountScheduleNameNotEmpty()
    begin
        if IsEmptyName(CopySourceAccScheduleName) then
            Error(CopySourceNameMissingErr);
    end;

    local procedure AssertSourceAccountScheduleNameExists(FromAccScheduleName: Record "Acc. Schedule Name")
    begin
        if not FromAccScheduleName.Get(CopySourceAccScheduleName) then
            Error(MissingSourceErr);
    end;

    local procedure AssertSourceAccountScheduleNameOnlyOne(var FromAccScheduleName: Record "Acc. Schedule Name")
    var
        AccScheduleName: Record "Acc. Schedule Name";
    begin
        AccScheduleName.CopyFilters(FromAccScheduleName);

        if AccScheduleName.Count() > 1 then
            Error(MultipleSourcesErr);
    end;
}