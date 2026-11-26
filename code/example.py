"""Minimal routing logic used by the example report."""


def route(score: float, evidence: str, threshold: float = 0.8) -> str:
    """Return 'auto' or 'review' for one document.

    The model proposes; the human reviewer makes the final decision.  A
    document goes to review when the score is low or no evidence span was
    extracted.
    """
    if score < threshold or not evidence.strip():
        return "review"
    return "auto"
