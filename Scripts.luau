-- Game Link : https://www.roblox.com/games/131234930559351/Math-Quiz
-- Youtube Game Review : https://www.youtube.com/watch?v=-lvnR9igbFY&ab_channel=PureSplashy

-- All SFX/SoundTracks made by me except firework SFX
 
-- MainQuizScript --
local QuizModel = script.Parent
local Screen = QuizModel.Screen
local ConfigFolder = QuizModel.Config
 
local Seat = QuizModel.Seat
 
local MainButtons = {
    StartButton = Screen.MainGui.MainButtons.StartButton,
    SubmitButton = Screen.MainGui.MainButtons.SubmitButton
}
 
local DifficultyButtons = {Screen.MainGui.DifficultyButtons.EasyButton,
    Screen.MainGui.DifficultyButtons.HardButton,
    Screen.MainGui.DifficultyButtons.InsaneButton
}
 
local Others = {
    QuestionText = Screen.MainGui.QuestionText,
    DifficultyText = Screen.MainGui.DifficultyText,
    TopText = Screen.MainGui.TopText,
    TimerText = Screen.MainGui.Timer
}
 
local AnswerBox = Screen.MainGui.AnswerBox
 
local StartEvent = game.ReplicatedStorage.StartEvent
local SubmitEvent = game.ReplicatedStorage.SubmitEvent
local DifficultyEvent = game.ReplicatedStorage.DifficultyEvent
local UpdateAnswerBoxEvent = game.ReplicatedStorage.UpdateAnswerBoxEvent
local EndRoundBindable = game.ServerStorage.EndRoundBindable
local ShootFireworksBindable = game.ServerStorage.ShootFireworksBindable
 
local Speaker = Screen.Speaker
 
--- --- --- --- --- --- --- --- --- ---
 
local function StartButton(Player, Button)
    
    if Player.Name == ConfigFolder.InteractingPlayer.Value then
        Speaker.Press:Play()
        
        MainButtons.StartButton.Visible = false
        Others.DifficultyText.Visible = true
        Others.QuestionText.Visible = false
 
        for i, Button in ipairs(DifficultyButtons) do
            Button.Visible = true
        end
    end
    
end
 
local function EndRound(Player)
    if ConfigFolder.QuizRunning.Value == true then
        ConfigFolder.QuizRunning.Value = false
        
        local ResultsScreenFolder = Screen.MainGui.Result
 
        MainButtons.SubmitButton.Visible = false
        AnswerBox.Visible = false
        Others.QuestionText.Visible = false
 
        for _, v in ResultsScreenFolder:GetChildren() do
            v.Visible = true
        end
        
        Speaker.TimeAttack.Playing = false
 
        ResultsScreenFolder.ResultText.Text = "SCORE : " .. ConfigFolder.QuestionNumber.Value
 
        if ConfigFolder.QuestionNumber.Value <= 3 then
            ResultsScreenFolder.Rating.Text = "WORSE"
            Speaker.Bad:Play()
        elseif ConfigFolder.QuestionNumber.Value <= 5 then
            ResultsScreenFolder.Rating.Text = "BAD"
            Speaker.Bad:Play()
        elseif ConfigFolder.QuestionNumber.Value <= 7 then
            ResultsScreenFolder.Rating.Text = "MEH"
            Speaker.Meh:Play()
        elseif ConfigFolder.QuestionNumber.Value <= 10 then
            ResultsScreenFolder.Rating.Text = "GOOD"
            ShootFireworksBindable:Fire(2)
            Speaker.Good:Play()
        elseif ConfigFolder.QuestionNumber.Value <= 15 then
            ResultsScreenFolder.Rating.Text = "GREAT"
            ShootFireworksBindable:Fire(5)
            Speaker.Great:Play()
        elseif ConfigFolder.QuestionNumber.Value > 15 then
            ResultsScreenFolder.Rating.Text = "EXCELLENT"
            ShootFireworksBindable:Fire(10)
            Speaker.Excellent:Play()
        end
        
        task.wait(3)
 
        for _, v in ResultsScreenFolder:GetChildren() do
            v.Visible = false
        end
        
    end
    
    ConfigFolder.Answer.Value = ""
    ConfigFolder.Difficulty.Value = "dif"
    ConfigFolder.QuestionNumber.Value = 0
    ConfigFolder.Timer.Value = 0
    ConfigFolder.PauseTimer.Value = true
 
    for _, v in Screen.MainGui:GetChildren() do
        if v:IsA("TextLabel") and v.Name ~= "Timer" and v.Name ~= "TopText" then
            v.Visible = false
        end
    end
    
    for _, v in ipairs(DifficultyButtons) do
        v.Visible = false
    end
    
    MainButtons.SubmitButton.Visible = false
    MainButtons.StartButton.Visible = true
    Others.QuestionText.Visible = true
    Others.QuestionText.Text = "Press START To Start Quiz"
    
    wait()
    
    if Player and Player.Character.Humanoid.Health >= 0 then
        if ConfigFolder.QuestionNumber.Value < 10 then
            Player.Character.Humanoid:TakeDamage(100)
            local Explosion = Instance.new("Explosion")
            Seat.ExplosionSoundEffect:Play()
            Explosion.BlastPressure = 599999
            Explosion.BlastRadius = 0.9
            Explosion.Position = Player.Character.HumanoidRootPart.Position
            Explosion.Parent = workspace
        else
            Player.Character.Humanoid.Sit = false
        end
    end
    
    if Player and Player.Character then
        local ResetCameraRemote = game.ReplicatedStorage.ResetCameraEvent
        ResetCameraRemote:FireClient(Player)
    end
    
end
 
local function PromptQuestion(Player)
    
    if Player.Name == ConfigFolder.InteractingPlayer.Value then
        
        ConfigFolder.PauseTimer.Value = false
        
        local TweenService = game:GetService("TweenService")
        local Info = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
        local Property = {TextColor3 = Color3.new(1, 1, 1)}
 
        local ColorTween = TweenService:Create(Others.QuestionText, Info, Property)
 
        Others.QuestionText.TextColor3 = Color3.new(0, 1, 0.08)
        ColorTween:Play()
        
        local Difficulty = ConfigFolder.Difficulty.Value
        
        QuizModel.Screen.MainGui.AnswerBox.Text = ""
        MainButtons.SubmitButton.Visible = true
 
        local RandomSpeech = {
            "What is ",
            "What's ",
            "Can you solve ",
            "Quick! Answer ",
            "Find the value of ",
            "Calculate ",
            "Solve ",
            "Tell me ",
            ""
        }
 
        local RandomNumber1
        local RandomNumber2
        local Signs = {}
        local MaxNumber = 10
 
        if Difficulty == "Easy" then
            Signs = {" + ", " - "}
            MaxNumber = 10
        elseif Difficulty == "Hard" then
            Signs = {" + ", " - ", " * "}
            MaxNumber = 50
        elseif Difficulty == "Insane" then
            Signs = {" + ", " - ", " * "}
            MaxNumber = 500
        end
 
        local ChosenSign = Signs[math.random(1, #Signs)]
        RandomNumber1 = math.random(0, MaxNumber)
        RandomNumber2 = math.random(0, MaxNumber)
        
        if Difficulty == "Hard" and ChosenSign == " * " then
            RandomNumber1 = math.random(0, 12)
            RandomNumber2 = math.random(0, 12)
        elseif Difficulty == "Insane" and ChosenSign == " * " then
            RandomNumber1 = math.random(0, 30)
            RandomNumber2 = math.random(0, 30)
        else
            RandomNumber1 = math.random(0, MaxNumber)
            RandomNumber2 = math.random(0, MaxNumber)
        end
 
        local Question = RandomSpeech[math.random(1, #RandomSpeech)] .. RandomNumber1 .. ChosenSign .. RandomNumber2
        Others.QuestionText.Text = Question
 
        local Answer
        
        if ChosenSign == " + " then
            Answer = RandomNumber1 + RandomNumber2
        elseif ChosenSign == " - " then
            Answer = RandomNumber1 - RandomNumber2
        elseif ChosenSign == " * " then
            Answer = RandomNumber1 * RandomNumber2
        end
 
        local AnswerValue = ConfigFolder.Answer
        AnswerValue.Value = Answer
        
    end
    
end
 
local function StartRound(Player, ButtonName)
    
    if Player.Name == ConfigFolder.InteractingPlayer.Value then
        
        local Difficulty
 
        Others.DifficultyText.Visible = false
        Others.QuestionText.Text = "Loading.."
        
        ConfigFolder.Timer.Value = 59
        ConfigFolder.QuizRunning.Value = true
 
        if ButtonName == "EasyButton" then
            Difficulty = "Easy"
        elseif ButtonName == "HardButton" then
            Difficulty = "Hard"
        elseif ButtonName == "InsaneButton" then
            Difficulty = "Insane"
        end
        
        Speaker.Press:Play()
        
        ConfigFolder.Difficulty.Value = Difficulty
        AnswerBox.Visible = true
 
        local OffsetCameraEvent = game.ReplicatedStorage.OffsetCameraEvent
        local NumpadBindable = game.ServerStorage.NumpadBindable
        
        NumpadBindable:Fire(Player)
        OffsetCameraEvent:FireClient(Player)
 
        for i, Button in ipairs(DifficultyButtons) do
            Button.Visible = false
        end
 
        Others.QuestionText.Visible = true
        AnswerBox.Text = ""
 
        for i = 3, 1, -1 do
            task.wait(1)
            if ConfigFolder.QuizRunning.Value == true then
                Others.QuestionText.Text = "Starting in " .. i
                
                if i == 1 then
                    Speaker.Three:Play()
                elseif i == 2 then
                    Speaker.Two:Play()
                elseif i == 3 then
                    Speaker.One:Play()
                end
                
            else
                break
            end
        end
        
        task.wait(1)
        
        if ConfigFolder.QuizRunning.Value == true then
            PromptQuestion(Player)
            Speaker.TimeAttack:Play()
        end
        
        warn("@" .. Player.Name .. " Started a " .. ConfigFolder.Difficulty.Value .. " Quiz")
        
    end
    
end
 
local function CheckAnswer(Player, Text)
    
    if Player.Name == ConfigFolder.InteractingPlayer.Value then
        
        local Answer = ConfigFolder.Answer
 
        if AnswerBox.Text == Answer.Value and ConfigFolder.Timer.Value > 0 then
            Speaker.Correct:Play()
            ConfigFolder.QuestionNumber.Value += 1
            PromptQuestion(Player)
        else
            local TweenService = game:GetService("TweenService")
            local Info = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
            local Property = {TextColor3 = Color3.new(1, 1, 1)}
 
            local ColorTween = TweenService:Create(Others.QuestionText, Info, Property)
 
            Others.QuestionText.TextColor3 = Color3.new(1, 0, 0.01)
            Speaker.Wrong:Play()
            ColorTween:Play()
        end
        
    end
    
end
 
local function Input(Player, Input)
    
    if Player.Name == ConfigFolder.InteractingPlayer.Value and ConfigFolder.PauseTimer.Value == false then
        
        local CurrentInput = AnswerBox.Text or ""
 
        if tonumber(Input) ~= nil then
            CurrentInput = CurrentInput .. Input
        elseif Input == "Backspace" then
 
            if #CurrentInput > 0 then
                CurrentInput = string.sub(CurrentInput, 1, #CurrentInput - 1)
            end
 
        elseif Input == "NegativeSign" then
 
            if string.sub(CurrentInput, 1, 1) == "-" then
                CurrentInput = string.sub(CurrentInput, 2)
            else
                CurrentInput = "-" .. CurrentInput
            end
 
        end
 
        AnswerBox.Text = CurrentInput
        
    end
    
end
 
ConfigFolder.Timer.Changed:Connect(function()
    if ConfigFolder.Timer.Value <= 0 and Seat.Occupant and Seat.Occupant.Parent and ConfigFolder.QuizRunning.Value == true then
 
        local Player = game.Players:GetPlayerFromCharacter(Seat.Occupant.Parent)
        if Player then
            EndRound(Player)
        end
        
    end
end)
 
StartEvent.OnServerEvent:Connect(StartButton)
SubmitEvent.OnServerEvent:Connect(CheckAnswer)
DifficultyEvent.OnServerEvent:Connect(StartRound)
UpdateAnswerBoxEvent.OnServerEvent:Connect(Input)
EndRoundBindable.Event:Connect(EndRound)
---END OF MainQuizScript---
