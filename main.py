import asyncio
from datetime import datetime, timedelta

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

from config import Settings

settings = Settings()
app = FastAPI(title=settings.app_name)


templates = Jinja2Templates(directory="templates")


class ActivityWatcher:
    last_request: datetime

    def update_last_request(self):
        self.last_request = datetime.now()

    async def start(self):
        self.last_request = datetime.now()
        while True:
            await asyncio.sleep(30)
            print(f"before condition {self.last_request=}")
            print(f"{self.last_request < datetime.now() - timedelta(seconds=25)=}")
            if self.last_request < datetime.now() - timedelta(seconds=25):
                import os
                import signal

                os.kill(os.getpid(), signal.SIGTERM)


activity_watcher = ActivityWatcher()


@app.on_event("startup")
async def startup_event():
    asyncio.create_task(activity_watcher.start())


@app.middleware("http")
async def update_last_request_middleware(request: Request, call_next):
    response = await call_next(request)
    activity_watcher.update_last_request()
    return response


@app.get("/", response_class=HTMLResponse, include_in_schema=False)
def landing_page(request: Request):
    return templates.TemplateResponse(
        "landing_page.html",
        {
            "request": request,
        },
    )
