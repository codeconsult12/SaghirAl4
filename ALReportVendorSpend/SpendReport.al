// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

report 50124 "Vendors Spend Report"
{
    UsageCategory = ReportsAndAnalysis;
    AdditionalSearchTerms = 'vendor, spend';
    ApplicationArea = All;
    DefaultLayout = RDLC;


    RDLCLayout = 'SpendReport.rdl';

    dataset
    {
        dataitem(Company; Company)
        {
            DataItemTableView = where(Name = filter('Ancora Innovation, LLC' | 'Blue One Biosciences, LLC' | 'Blue Q Biosciences LLC' |
'Bluefield Innovations, LLC' | 'Deerfield D&D, LLC' | 'Exohalt Therapeutics, LLC' | 'Galium Biosciences LLC' |
'Hudson Heights Innovations LLC' | 'Lab1636, LLC' | 'Lakeside Discovery, LLC' | 'Pinnacle Hill, LLC' | 'Poseidon Innovation, LLC' | 'West Loop Innovations, LLC'));
            column(Name; Name) { }
            dataitem(VLE; "Vendor Ledger Entry")
            {
                column(filter; VLE.GetFilters()) { }
                column(Vendor_No_; "Vendor No.") { }
                column(Amount; Amount) { }
                dataitem(Vendor; Vendor)
                {
                    DataItemLink = "No." = Field("Vendor No.");
                    //                    SqlJoinType = InnerJoin;
                    column(VendorName; Name) { }
                }
                trigger OnPreDataItem()

                begin
                    SetFilter("Document Type", '%1', "Document Type"::Invoice);
                end;


                trigger OnAfterGetRecord()
                begin
                    //Vendor.ChangeCompany(CompanyName);
                end;
            }
            //          trigger OnPreDataItem()
            //        begin
            //                Company.SetFilter(Name, '=%1|=%2', 'ABC', '');
            //              if Company.FindSet() then
            //                repeat
            //                  message(Name);
            //                VLE.ChangeCompany(Name);
            //              Vendor.ChangeCompany(Name);
            //        until Company.Next() = 0;
            //message(Name);
            //if
            //(Name <> 'ABC')

            //                then begin
            //    message(Name);
            //    VLE.ChangeCompany(Name);
            //    Vendor.ChangeCompany(Name);

            //      end;

            trigger OnAfterGetRecord()
            begin
                //            Message(Name);
                //          if Name = 'ABC' then begin
                //            Message(Name);
                VLE.ChangeCompany(Name);
                Vendor.ChangeCompany(Name);
            end;
            //end;
            //begin


        }
    }


}

pageextension 50111 VendorSpendReportExt extends "Business Manager Role Center"
{
    layout
    {

    }
    actions
    {
        addafter("Excel Reports")
        {
            action("Vendor Spend Report")
            {
                Caption = 'Vendor Spend Report';
                Image = Report2;
                Promoted = true;
                PromotedCategory = Report;
                RunObject = report "Vendors Spend Report";
                ApplicationArea = All;
            }
        }
    }
}