import re


CATEGORY_KEYWORDS = {
    "Food": [
        r"\bzomato\b",
        r"\bswiggy\b",
        r"\brestaurant\b",
        r"\bcafe\b",
        r"\bdinner\b",
        r"\blunch\b",
        r"\bbreakfast\b",
        r"\bsnacks?\b",
        r"\bcoffee\b",
        r"\btea\b",
        r"\bpizza\b",
        r"\bburger\b",
        r"\bgrocer(y|ies)\b",
        r"\bfood\b",
        r"\bmeal\b",
    ],
    "Transport": [
        r"\buber\b",
        r"\bola\b",
        r"\btaxi\b",
        r"\bmetro\b",
        r"\bfuel\b",
        r"\bpetrol\b",
        r"\bdiesel\b",
        r"\bbus\b",
        r"\bauto\b",
        r"\btrain\b",
        r"\bflight\b",
        r"\bcab\b",
        r"\bparking\b",
        r"\btoll\b",
        r"\bride\b",
        r"\btravel\b",
    ],
    "Shopping": [
        r"\bamazon\b",
        r"\bflipkart\b",
        r"\bmall\b",
        r"\bshopping\b",
        r"\bstore\b",
        r"\bmyntra\b",
        r"\bajio\b",
        r"\border\b",
        r"\bclothes?\b",
        r"\bdress\b",
        r"\bshoes?\b",
        r"\bbag\b",
        r"\bpurchase\b",
        r"\bbought\b",
    ],
    "Bills": [
        r"\belectricity\b",
        r"\binternet\b",
        r"\bwater bill\b",
        r"\brent\b",
        r"\brecharge\b",
        r"\bwifi\b",
        r"\bbroadband\b",
        r"\bpostpaid\b",
        r"\bprepaid\b",
        r"\bbill\b",
        r"\bemi\b",
        r"\bsubscription\b",
        r"\bfees?\b",
        r"\btuition\b",
        r"\bschool fee\b",
        r"\bmaintenance\b",
    ],
    "Health": [
        r"\bmedical\b",
        r"\bmedicine\b",
        r"\bdoctor\b",
        r"\bhospital\b",
        r"\bclinic\b",
        r"\bpharmacy\b",
        r"\btablet\b",
        r"\bcheckup\b",
        r"\bhealth\b",
        r"\blab\b",
        r"\bscan\b",
        r"\bdental\b",
        r"\btherapy\b",
        r"\bconsultation\b",
    ],
    "Entertainment": [
        r"\bmovie\b",
        r"\bnetflix\b",
        r"\bspotify\b",
        r"\bgame\b",
        r"\bconcert\b",
        r"\bcinema\b",
        r"\bhotstar\b",
        r"\bprime video\b",
        r"\byoutube\b",
        r"\bparty\b",
        r"\bouting\b",
        r"\bfun\b",
        r"\bplay\b",
    ],
}


def categorize_expense(note: str, category: str | None) -> str:
    if category is not None and category.strip():
        return category.strip().title()

    lowered_note = note.lower().strip()

    for mapped_category, patterns in CATEGORY_KEYWORDS.items():
        if any(re.search(pattern, lowered_note) for pattern in patterns):
            return mapped_category

    return "Other"
