#!/bin/bash

fisier_parole="parole.enc" #aici vom salva parolele criptate
fisier_temp_parole="parole.tmp" #aici vom putea vizualiza parolele dupa decriptare, daca suntem master, normal

verificare_parola_corecta(){
     if [[ -f "$fisier_parole" ]]; then
        while true; do
           echo -n "Introdu parola: "
           read -s parola_admin

           openssl enc -aes-256-cbc -d -in "$fisier_parole" -out "$fisier_temp_parole" -k "$parola_admin" 2>/dev/null
           if [[ $? -eq 0 ]]; then
              break
           else
             echo
             echo "Parola incorecta!"
           fi
       done
    else
      echo "Aceasta este prima rulare a scriptului. Seteaza o parola puternica!"
      while true; do
         echo -n "Introdu parola principala: "
         read -s parola_admin
         echo
         echo -n "Confirma parola principala: "
         read -s parola_admin_confirmare
         echo

         if [[ "$parola_admin" == "$parola_admin_confirmare" ]]; then
             echo "Parola a fost setata cu succes"
             break
         else
            echo "Parolele nu coincid. Te rog sa incerci din nou."
         fi
      done

      echo "Cream fisier temporar de parole" > "$fisier_temp_parole"
      openssl enc -aes-256-cbc -e -in "$fisier_temp_parole" -out "$fisier_parole" -k "$parola_admin"
      rm -f "$fisier_temp_parole"
      echo "Fisierul de parole a fost creat si criptat cu parola principala."
   fi
}

main_menu(){

   while true; do
      echo
      echo "==== Manager Simplu de Parole ===="
      echo "1. Adauga o parola"
      echo "2. Vizualizeaza parolele"
      echo "3. Sterge o parola"
      echo "4. Resetarea parolei"
      echo "5. Iesire"
      echo -n "Alege o optiune: "
      read choice

      case $choice in
      1) add_password
         ;;
      2) view_password
         ;;
      3) delete_password
         ;;
      4) reset_password
         ;;
      5)
        openssl enc -aes-256-cbc -e -in "$fisier_temp_parole" -out "$fisier_parole" -k "$parola_admin"
        rm -f "$fisier_temp_parole"
        echo "La revedere!"
        exit 0
        ;;
      *) echo "Optiune invalida!"
        ;;
     esac
   done
}

add_password(){
   echo
   echo
   echo -n "Introdu numele serviciului: "
   read service
   while true; do
      echo -n "Introdu parola pentru $service: "
      read -s parola
      echo
      echo -n "Confirmarea parolei pentru $service: "
      read -s parola_verificare

      if [[ "$parola" == "$parola_verificare" ]]; then
         echo
         echo "$service:$parola" >> "$fisier_temp_parole"
         echo "Parola a fost salvata cu succes!"
         break
      else
         echo "Parolele nu coincid!"
      fi
   done
}

view_password(){
   echo
   echo
   echo "Parole salvate: "
   cat "$fisier_temp_parole" | while read line; do
      service=$(echo "$line" | cut -d':' -f1)
      parola=$(echo "$line" | cut -d':' -f2)
      echo "Serviciu: $service | Parola: $parola"
   done

}

delete_password(){
   verificare=0
   echo
   echo
   echo -n "Introdu numele serviciului pentru stergere: "
   read service
   while read line; do
       service_fisier=$(echo $line | cut -d':' -f1)
       if [[ "$service" == "$service_fisier" ]]; then
          verificare=$((verificare+1))
       fi
   done < "$fisier_temp_parole"

   if [[ $verificare -ge 1 ]]; then
       grep -v "^$service:" "$fisier_temp_parole" > "$fisier_temp_parole.new"
       # -v inverseaza rezultatul comenzii grep. adica seleceaza toate liniile care nu se potrivesc cu expresia regulata si le scrie intr un fisier nou

       mv "$fisier_temp_parole.new" "$fisier_temp_parole"
       echo "Parola pentru $service a fost stearsa!"
  else
     echo "Serviciul nu a fost gasit!"
  fi

}

reset_password(){
    echo "Atentie! Aceasta actiune va sterge toate parolele salvate!"
    echo -n "Esti sigur ca doresti sa continui? (Y/N): "
    read raspuns

    if [[ "$raspuns" == "Y" || "$raspuns" == "y" || "$raspuns" == "da" || "$raspuns" == "DA" || "$raspuns" == "yes" || "$raspuns" == "Yes" ]]; then
       echo -n "Esti sigur sigur? (Y/N): "
       read raspunsfinal
          if [[ "$raspunsfinal" == "Y" || "$raspunsfinal" == "y" || "$raspunsfinal" == "da" || "$raspunsfinal" == "DA" || "$raspunsfinal" == "yes" || "$raspunsfinal" == "Yes" ]]; then
             rm -f "$fisier_parole" "$fisier_temp_parole"
             echo "Fisierul de parole a fost sters."
             exit 0
          else
             echo "Resetarea parolei principale a fost anulata."
          fi
     else
       echo "Resetarea parolei principale a fost anulata."
     fi

}


verificare_parola_corecta
main_menu
