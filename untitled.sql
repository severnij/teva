
WITH sales_info AS (

	SELECT
		DP.ID_Product,
		ISNULL(DP.FullNameEn, '') AS SKU,  
		ISNULL(PS.TevaCode, 0) AS TevaCode, 
		ISNULL(DBr.BrandNameEn, '') AS Brand, 
  		ISNULL(DBr.BrandGroup, '') AS Brand_Group, 
  		ISNULL(DSg.Segment, '') AS Segment, 
  		ISNULL(DSSg.SubSegment, '') AS SubSegment, 
  		ISNULL(DBU.BUName, '') AS BUName, 

	FROM SALESINFO.dbo.DICT_Prod AS DP
		LEFT OUTER JOIN (
      		SELECT
        		TevaCode, 
        		IdBrand, 
        		IdSegment, 
        		IdSubSegment, 
        		BU
      		FROM SALESINFO.dbo.t_ProdSegmentation
      		WHERE
        		(DDFrom = '20200101')
    	) AS PS
      			ON PS.TevaCode = DP.TevaCode 
      		LEFT OUTER JOIN SALESINFO.dbo.DICT_Brands AS DBr 
      				ON DBr.IdBrand = PS.IdBrand 
      		LEFT OUTER JOIN SALESINFO.dbo.DICT_Segments AS DSg 
      				ON DSg.IDSegment = PS.IdSegment 
      		LEFT OUTER JOIN SALESINFO.dbo.DICT_SubSegment AS DSSg 
      				ON DSSg.IDSubSegment = PS.IdSubSegment 
      		LEFT OUTER JOIN SALESINFO.dbo.DICT_BU AS DBU 
      				ON DBU.BU = PS.BU 

)

SELECT
	rep.Year, 
  	rep.Week, 
  	rep.DistributorId, 
  	DataType.DataType, 
	SUM(F_EX.Units) AS QTY, 
  	SUM(F_EX.Units) * Price.Price AS RUR, 
	si.ID_Product,
    si.SKU,
    si.TevaCode,
    si.Brand,
    si.Brand_Group,
    si.Segment,
    si.SubSegment,
    si.BUName,
    ISNULL(Distr_T.DistributorName, '') AS DistributorName, 
    Subsidiary.ID_Subsidiary,
    ISNULL(Subsidiary.SubsidiaryName, '') AS SubsidiaryName, 
    c.CName AS DFiliale_City,

FROM [dbo].[V_SA_Facts_uni]  AS F_EX
	INNER JOIN V_SA_Reports_I AS rep 
			ON (
					F_EX.ReportId = rep.ReportId 
					AND F_EX.DistributorId = rep.DistributorId 
			)
		INNER JOIN DataType
			ON rep.DataTypeCode = DataType.Id
	LEFT JOIN sales_info AS si
			ON F_EX.ProductId = si.ID_Product
	LEFT OUTER JOIN SALESINFO.dbo.DistributorTable AS Distr_T 
      		ON F_EX.DistributorId = Distr_T.DistributorCode 
    LEFT OUTER JOIN SALESINFO.dbo.DICT_Subsidiary AS Subsidiary 
      		ON F_EX.[ID_Subsidiary] = Subsidiary.ID_Subsidiary 
    	LEFT OUTER JOIN SALESINFO.dbo.DICT_City AS c 
    			ON c.ID_City = Subsidiary.Id_City
    LEFT OUTER JOIN (
    	SELECT        
        	idProd, 
        	Price
      	FROM SALESINFO.dbo.tbPrice
      	WHERE (idPriceType = 80)
  	) AS Price 
    		ON Price.idProd = F_EX.ProductId 


WHERE
    (rep.DataTypeCode IN (7, 8)) AND (rep.Year >= 2019)

GROUP BY
	rep.Year, 
    rep.Week, 
    rep.DistributorId, 
    DataType.DataType, 
    si.ID_Product,
    si.SKU,
    si.TevaCode,
    si.Brand,
    si.Brand_Group,
    si.Segment,
    si.SubSegment,
    si.BUName,
    Distr_T.DistributorName, 
    Subsidiary.ID_Subsidiary,
    Subsidiary.SubsidiaryName, 
    c.CName,
    Price.Price