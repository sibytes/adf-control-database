CREATE procedure [test].[get_result]
  @@run_id uniqueidentifier
as
begin

  select 
      [id],
      [run_id],
      [test], 
      [expected], 
      [actual], 
      [executed_at],
      [result] 
  from [test].[result]
  where [run_id] = @@run_id;


  declare @failed int = (
    select count(1) 
    from [test].[result] 
    where result = 'FAILED' 
      and [run_id] = @@run_id
  )

  if (@failed > 0)
  begin
      declare @msg varchar(50) = FORMATMESSAGE( '%i or more tests failed.', @failed);
      throw 60000, @msg, 1;
  end

end

GO

