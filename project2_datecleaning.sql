select * from PortfolioProject..Housing
------------------------------------------------------------------------
-- STANDARDIZE DATE FORMAT

select SaleDate, CONVERT(DATE, SaleDate) AS DATE
from PortfolioProject..Housing

ALTER TABLE Housing
ADD CONVERTEDDATE DATE;

UPDATE Housing
SET CONVERTEDDATE = CONVERT(DATE, SaleDate)

select CONVERTEDDATE, CONVERT(DATE, SaleDate) AS DATE
from PortfolioProject..Housing
-------------------------------------------------------------------------------------------
-- PROPERTY ADDRESS 
SELECT * FROM PortfolioProject..Housing
ORDER BY  ParcelID 

SELECT H1.ParcelID, H1.PropertyAddress,H2.ParcelID,H2.PropertyAddress, 
ISNULL(H1.PropertyAddress, H2.PropertyAddress) AS UPDATEDADDRESS
FROM PortfolioProject..Housing H1
JOIN PortfolioProject..Housing  H2 
ON H1.ParcelID = H2.ParcelID
AND H1.[UniqueID ] <> H2.[UniqueID ]
WHERE H1.PropertyAddress IS NULL

UPDATE H1
SET PROPERTYADDRESS = ISNULL(H1.PropertyAddress, H2.PropertyAddress) 
FROM PortfolioProject..Housing H1
JOIN PortfolioProject..Housing  H2 
ON H1.ParcelID = H2.ParcelID
AND H1.[UniqueID ] <> H2.[UniqueID ]
WHERE H1.PropertyAddress IS NULL

SELECT ParcelID, PROPERTYADDRESS FROM PortfolioProject..Housing
-- WHERE PROPERTYADDRESS IS  NULL
ORDER BY ParcelID
----------------------------------------------------------------------------------------------
-- BREAKING PROPERTYAddress (ADDRESS, CITY, STATE)
select propertyaddress from PortfolioProject..Housing

   --1st part of address 
select SUBSTRING(propertyaddress,1,CHARINDEX(', ' , propertyaddress)-1) as Address
--,CHARINDEX(',' , propertyaddress)
from PortfolioProject..Housing

-- 2nd part of address 
select SUBSTRING(propertyaddress,1,CHARINDEX(', ' , propertyaddress)-1) as Address1,
SUBSTRING(propertyaddress,CHARINDEX(', ' , propertyaddress) +1,len(propertyaddress)) as Address2
from PortfolioProject..Housing
order by SUBSTRING(propertyaddress,CHARINDEX(', ' , propertyaddress) +1,len(propertyaddress)) 


ALTER TABLE PortfolioProject..Housing
ADD ProperAddress1stpart nvarchar(255);

UPDATE PortfolioProject..Housing
SET ProperAddress1stpart = SUBSTRING(propertyaddress,1,CHARINDEX(', ' , propertyaddress)-1) 

ALTER TABLE PortfolioProject..Housing
ADD ProperAddress2ndpart nvarchar(255);

UPDATE PortfolioProject..Housing
SET ProperAddress2ndpart = SUBSTRING(propertyaddress,CHARINDEX(', ' , propertyaddress) +1,len(propertyaddress))

SELECT ProperAddress1stpart, ProperAddress2ndpart FROM PortfolioProject..Housing

-- BREAKING OwnerAddress (ADDRESS, CITY, STATE)

select OwnerAddress from PortfolioProject..Housing

select PARSENAME(replace(OwnerAddress,',','.'),3) as street,
PARSENAME(replace(OwnerAddress,',','.'),2) as city,
PARSENAME(replace(OwnerAddress,',','.'),1) as state
from PortfolioProject..Housing
where PARSENAME(replace(OwnerAddress,',','.'),3) is not null and
PARSENAME(replace(OwnerAddress,',','.'),2) is not null and
PARSENAME(replace(OwnerAddress,',','.'),1) is not null
order by PARSENAME(replace(OwnerAddress,',','.'),2) 


ALTER TABLE PortfolioProject..Housing
ADD ownerAddresssreet nvarchar(255);

UPDATE PortfolioProject..Housing
SET ownerAddresssreet = PARSENAME(replace(OwnerAddress,',','.'),3)

select ownerAddresssreet from  PortfolioProject..Housing
where ownerAddresssreet is not null

ALTER TABLE PortfolioProject..Housing
ADD ownerAddresscity nvarchar(255);

UPDATE PortfolioProject..Housing
SET ownerAddresscity = PARSENAME(replace(OwnerAddress,',','.'),2)
 
 ALTER TABLE PortfolioProject..Housing
ADD ownerAddressstate nvarchar(255);

UPDATE PortfolioProject..Housing
SET ownerAddressstate = PARSENAME(replace(OwnerAddress,',','.'),1)

select ownerAddresssreet,  ownerAddresscity ,ownerAddressstate from  PortfolioProject..Housing
--where ownerAddresssreet is not null and ownerAddresscity is not null and ownerAddressstate is not null


----------------------------------------------------------------------------------------------------------------
-- change y , n, yes , no to sold and vacant

select distinct(SoldAsVacant), count(SoldAsVacant) from   PortfolioProject..Housing
group by SoldAsVacant
order by 2  

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
      else SoldAsVacant 
	  end
from   PortfolioProject..Housing

update PortfolioProject..Housing

set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
      else SoldAsVacant 
	  end

-------------------------------------------------------------------------------------------------------------

--remove duplicates

select *, 
ROW_NUMBER() over(
partition by parcelID,propertyAddress, Saleprice, Saledate, LegalReference 
order by uniqueId ) row_num
from   PortfolioProject..Housing
order by ParcelID

with rownumCTE AS (
select *, 
ROW_NUMBER() over(
partition by parcelID,propertyAddress, Saleprice, Saledate, LegalReference 
order by uniqueId ) row_num
from   PortfolioProject..Housing)


SELECT * FROM rownumCTE
WHERE row_num > 1
ORDER BY propertyAddress




with rownumCTE AS (
select *, 
ROW_NUMBER() over(
partition by parcelID,propertyAddress, Saleprice, Saledate, LegalReference 
order by uniqueId ) row_num
from   PortfolioProject..Housing)


DELETE FROM rownumCTE
WHERE row_num > 1
----------------------------------------------------------------------------------------------------------------

--REMOVE UNUSED COLUMN 

ALTER TABLE PortfolioProject..Housing
DROP COLUMN OWNERADDRESS, TAXDISTRICT, PROPERTYADDRESS

SELECT * FROM PortfolioProject..Housing

ALTER TABLE PortfolioProject..Housing
DROP COLUMN SALEDATE


