select distinct v3."Form Name" as v3_form
     , v3."Variable / Field Name"
     , v2."Form Name" v2_form
  from dict_v3 v3
  left join dict_v2 v2
    on v2."Variable / Field Name" = v3."Variable / Field Name"
 where v3."Field Type" not in('descriptive','calc');

/***
CREATE TABLE dict_v3(
  "Variable / Field Name" TEXT,
  "Form Name" TEXT,
  "Section Header" TEXT,
  "Field Type" TEXT,
  "Field Label" TEXT,
  "Choices, Calculations, OR Slider Labels" TEXT,
  "Field Note" TEXT,
  "Text Validation Type OR Show Slider Number" TEXT,
  "Text Validation Min" TEXT,
  "Text Validation Max" TEXT,
  "Identifier?" TEXT,
  "Branching Logic (Show field only if...)" TEXT,
  "Required Field?" TEXT,
  "Custom Alignment" TEXT,
  "Question Number (surveys only)" TEXT,
  "Matrix Group Name" TEXT,
  "Matrix Ranking?" TEXT,
  "Field Annotation" TEXT
);
***/
