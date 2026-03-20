
use biblioteca;
delimiter //
create procedure prova1()
begin

 start transaction;
 update autori set vendite = vendite + 100 where idAutore=2;
 update autori set vendite = vendite + 100 where idAutore=1;
 set @c=0;
 select vendite into @c from autori where idAutore=2;
 if(@c>1000)
   then commit;
   else rollback;
 end if;

end//
delimiter ;

call prova1;