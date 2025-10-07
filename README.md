HabitTracker App with SwiftUi and Swift Data

Projektlogg - HabitTracker App

Datum: 2025-04-29

Sammanfattning av dagens arbete:

Jag började idag planera för min Habit Tracker-app och funderade på vilka funktioner jag vill att appen ska ha. Syftet med appen är att hjälpa användare att hålla reda på och upprätthålla sina vanor och mål, så jag har fokuserat på att skapa en användarvänlig och engagerande upplevelse. Här är de grundläggande funktionerna jag har planerat:

1. Lista över vanor: En vy där användaren kan se alla vanor de har lagt till, inklusive namnet på vanan, emoji och streak (antal dagar i rad som vanan har utförts).

2. Lägga till nya vanor: Jag planerar att ge användaren möjlighet att skapa en ny vana genom att ange ett namn, välja en emoji och välja en färg för att göra varje vana mer personlig och visuellt tilltalande.

3. Markera vanor som utförda: En funktion/knapp där användaren kan markera om de har utfört en vana under dagen.

4. Streaks: En funktion som håller reda på antalet dagar i rad som användaren har utfört en vana. Detta kommer att hjälpa användare att skapa och bibehålla en vana genom att se sina framsteg.

5. Statistik: Jag planerar att skapa en vy som sammanställer användarens framsteg, med statistik för varje dag, vecka och månad. Detta ger användaren en översikt av sina prestationer och kan fungera som motivation.

Val av databas (SwiftData)
Jag valde att använda SwiftData som databas för appen. Eftersom appen kommer att lagra och hämta användardata (som vanor, påminnelser och streaks), känns SwiftData som ett bra val. Det är integrerat med SwiftUI, vilket gör det enklare att implementera funktionerna och spara data lokalt på användarens enhet. Eftersom jag inte planerar att använda någon extern server eller autentisering, kommer SwiftData att vara ett bra alternativ för att säkerställa att användarens vanor sparas och laddas upp vid behov.

Datum: 2025-04-30

Sammanfattning av dagens arbete:

Idag har jag arbetat med att skapa grundstrukturen för appen med SwiftUI och börjat implementerat flera viktiga funktioner som kommer att utgöra basen för appen. Här är de specifika aktiviteterna jag har genomfört:

dHabitView.swift

Jag valde att arbeta med denna vy eftersom den utgör en central del av användarupplevelsen – det är här användaren skapar sina nya vanor. Mitt fokus låg på att göra det enkelt men också visuellt engagerande. Jag valde att använda en Form för att strukturera inmatningen tydligt och logiskt.

För att göra vanorna mer personliga och lättigenkännliga lade jag till en emoji-väljare och en färgväljare med fördefinierade hex-koder. Detta ger varje vana en visuell identitet. Jag ville också stödja vanebyggande genom att erbjuda möjligheten att ställa in dagliga påminnelser. För det använde jag UNUserNotificationCenter.

Jag valde att använda @State för att hantera lokalt tillstånd i vyn och @Environment för att kunna spara nya vanor i databasen och stänga vyn efteråt. En alert visas när en påminnelse sätts – det ger användaren direkt feedback. Jag valde också att bara tillåta sparande av vanor om namn är ifyllt, som en enkel validering.

Habit.swift

Här skapade jag den centrala datamodellen för vanorna. Jag valde att kombinera både logik och data i denna @Model-klass eftersom det gör modellen mer kraftfull och självbärande. Det kändes viktigt att inkludera både visuella egenskaper (emoji, färg) och funktionella (påminnelse, streak-logik).

Jag valde att använda @Relationship med .cascade för att automatiskt ta bort tillhörande completion-poster om en vana raderas – det ger en ren databas. Jag implementerade också isCompletedToday som en computed property för att enkelt kunna kolla om en vana redan registrerats idag.

Extensions.swift

Jag skapade en extension för att kunna använda hex-koder till färger, eftersom det gör designen mer flexibel och professionell. Jag valde att stödja olika hex-format (t.ex. 3, 6 och 8 tecken) för att göra funktionen mer robust och återanvändbar.

Jag använde Scanner och bitmanipulation för att konvertera strängar till färgkomponenter, och standardfärgen svart används som fallback vid ogiltig input. Jag ville hålla implementationen ren och enkel, samtidigt som den löste ett verkligt behov i appen.

HabitTrackerApp.swift

Jag arbetade också med själva startpunkten för appen, där jag satte upp allt som behövs när appen startar. Jag valde att centralisera notishanteringen genom en NotificationManager, vilket gör det enklare att hantera tillstånd och notislogik.

Jag begär tillstånd för notifikationer direkt vid appstart, eftersom det är en viktig del av appens funktion. Jag använde @main och @StateObject för att hålla instanserna levande genom hela appens livscykel.

ContentView.swift

Jag valde att designa huvudvyn på ett sätt som anpassar sig efter om användaren har några vanor registrerade eller inte. Det ger en mer dynamisk och personlig upplevelse. Om inga vanor finns visas en tomvy (EmptyHabitsView) för att guida användaren.

Jag inkluderade även logik för att validera streaks direkt när vyn visas. För att hjälpa användaren hålla sig konsekvent skickas en daglig påminnelse kl 23 om inga vanor markerats – detta är ett försök att bryta dåliga vanor och främja reflektion.

Jag använde @Query för att automatiskt hålla listan uppdaterad och delade upp UI:t i mindre komponenter som HabitRowView för att göra koden mer hanterbar. En enkel statistikvy öppnas som ett sheet, vilket gör det smidigt att få en överblick utan att lämna huvudvyn.


Datum: 2025-05-05

Sammanfattning av dagens arbete:

Idag har jag arbetat med att bygga funktioner för att hantera och visa slutförda vanor samt skapa en statistikvy som ger användaren en översikt över sina framsteg. Jag har arbetat på både HabitCompletion.swift och StatisticsView.swift för att skapa grundläggande funktionalitet för att följa vanor och mäta framsteg.

HabitCompletion.swift

Jag började med att skapa en modellklass för att representera när en vana har slutförts. Detta är en central funktion för att hålla reda på användarens framsteg. 

Jag definierade en modell som lagrar information om en genomförd vana. Den har egenskaper som date (datumet då vanan slutfördes) och en referens till habit (den specifika vana som slutfördes). Detta gör att appen kan hålla reda på när och vilken vana användaren slutfört.

Jag använde @Model för att koppla modellen till SwiftData, vilket gör det möjligt att lagra och hämta information om slutförda vanor från den lokala databasen.

Jag tänkte på hur denna modell skulle användas i statistikdelen av appen, så jag såg till att informationen om slutförda vanor var lätt att hämta och använda för att skapa statistik om användarens framsteg.

StatisticsView.swift

När HabitCompletion-modellen var på plats, började jag arbeta på en statistikvy för att visa användarens framsteg på ett överskådligt sätt. 

Jag designade vyn för att visa statistik om användarens vanor, som exempelvis deras streak (antal dagar i rad med slutförda vanor) och completion rate (procentandel slutförda vanor jämfört med målen). Detta ger användaren en snabb och tydlig översikt.

Jag använde grafiska element som staplar och diagram för att representera statistik visuellt. Jag implementerade också dynamiska etiketter för att visa användarens aktuella statistik (t.ex. “3 dagar i rad” eller “85% fullföljande”).

Jag såg till att statistikvyn var lättillgänglig genom att göra den tillgänglig som ett sheet från huvudvyn. Det gör det enkelt för användaren att få en överblick över sina framsteg utan att navigera bort från huvudflödet.

Jag planerade att lägga till fler statistikmått framöver, som månatliga sammanfattningar och detaljerad data om varje vana. Detta kommer att ge användaren mer insikt i sina vanor och hjälpa till att sätta mål.


Datum: 2025-05-12

Sammanfattning av dagens arbete:

Idag har jag gjort några små justeringar och förbättringar i appen för att förbättra användarupplevelsen och få funktionerna att flyta bättre. 

Kalenderfunktion och färgade dots för vanor

Jag har lagt till en kalenderfunktion där varje dag visas med en punkt (dot) som markeras beroende på om användaren har slutfört vanan för den dagen. Färgen på denna punkt matchar den färg användaren har valt för sin vana, vilket gör det visuellt lätt att följa sina framsteg under månaden. Detta ger användaren en snabb översikt över hur bra de håller sina vanor.

Notiser för nya vanor och påminnelse om streak

Jag fixade så att användaren får en notis när de ställer in en tid för en ny vana. Jag såg även till att en påminnelse skickas ut klockan 23:00 varje dag om användaren ännu inte har markerat sin vana som slutförd för den dagen. Detta påminner användaren om att deras streak kan brytas om de inte slutför vanan innan dagen är slut. Detta hjälper till att hålla motivationen uppe och förstärker vanebildningen.

Uppdaterad design i StatisticsView

Jag ändrade utseendet på statistikvyn till en mer minimalistisk och stilren design, som jag tycker är både snyggare och enklare att navigera i. Jag fokuserade på att göra den visuellt tilltalande utan att göra den för rörig. Statistiken är nu lättare att ta till sig och passar bättre med appens övergripande design.

Kommentering och förklaringar i koden

Jag gick igenom hela koden för dagens uppdateringar och lade till kommentarer för att förklara både större och mindre delar av koden. Jag skrev förklaringar för hela funktioner såväl som för specifika rader. Detta gör det lättare att förstå hur koden fungerar och underlättar framtida utveckling och felsökning.





Core Features:
Daily Tracking: Mark habits as completed and watch your streaks grow.
Streak System: Automatically calculates consecutive days of completion.
Statistics Dashboard: Visual overview of your past 7 days with completion rates and activity circles.
Smart Reminders: Daily local notifications that help users stay on track.
Customization: Choose emoji and color for each habit for a more personal experience.
Local Persistence with SwiftData: All data is stored locally and updates in real time.


Tech Stack:
SwiftUI for modern, declarative UI
SwiftData for local data storage
UserNotifications for reminders
MVVM architecture for maintainability and scalability

